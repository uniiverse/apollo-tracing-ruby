# frozen_string_literal: true

require "graphql"
require "apollo_tracing/version"

class ApolloTracing
  def self.start_proxy(config_filepath_or_json = 'config/apollo-engine.json')
    config_json =
      if File.exist?(config_filepath_or_json)
        File.read(config_filepath_or_json)
      else
        config_filepath_or_json
      end
    binary_path =
      if RUBY_PLATFORM.include?('darwin')
        File.expand_path('../../bin/engineproxy_darwin_amd64', __FILE__)
      elsif /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
        File.expand_path('../../bin/engineproxy_windows_amd64.exe', __FILE__)
      else
        File.expand_path('../../bin/engineproxy_linux_amd64', __FILE__)
      end

    @@proxy_pid = spawn(
      {"ENGINE_CONFIG" => config_json},
      "#{binary_path} -config=env -restart=true",
      {out: STDOUT, err: STDERR}
    )
    at_exit { stop_proxy }
    Process.detach(@@proxy_pid)
    @@proxy_pid
  end

  def self.stop_proxy
    Process.getpgid(@@proxy_pid)
    Process.kill('TERM', @@proxy_pid)

    3.times do
      Process.getpgid(@@proxy_pid)
      sleep 1
    end

    Process.getpgid(@@proxy_pid)
    puts "Couldn't cleanly terminate the Apollo Engine Proxy in 3 seconds!"
    Process.kill('KILL', @@proxy_pid)
  rescue Errno::ESRCH
    # process does not exist
  end

  def use(schema_definition)
    schema_definition.instrument(:query, self)
    schema_definition.instrument(:field, self)
  end

  def before_query(query)
    query.context['apollo-tracing'] = {
      'start_time' => Time.now.utc,
      'resolvers' => []
    }
  end

  def after_query(query)
    result = query.result
    end_time = Time.now.utc
    duration_nanos = duration_nanos(start_time: query.context['apollo-tracing']['start_time'], end_time: end_time)

    result["extensions"] ||= {}
    result["extensions"]["tracing"] = {
      "version" => 1,
      "startTime" => query.context['apollo-tracing']['start_time'].strftime('%FT%T.%3NZ'),
      "endTime" => end_time.strftime('%FT%T.%3NZ'),
      "duration" => duration_nanos,
      "execution" => {
        "resolvers" => query.context['apollo-tracing']['resolvers']
      }
    }
  end

  def instrument(type, field)
    old_resolve_proc = field.resolve_proc

    new_resolve_proc = ->(obj, args, ctx) do
      resolve_start_time = Time.now.utc
      result = old_resolve_proc.call(obj, args, ctx)
      resolve_end_time = Time.now.utc

      ctx['apollo-tracing']['resolvers'] << {
        'path' => ctx.path,
        'parentType' => type.name,
        'fieldName' => field.name,
        'returnType' => field.type.to_s,
        'startOffset' => duration_nanos(start_time: ctx['apollo-tracing']['start_time'], end_time: resolve_start_time),
        'duration' => duration_nanos(start_time: resolve_start_time, end_time: resolve_end_time)
      }

      result
    end

    field.redefine { resolve(new_resolve_proc) }
  end

  private

  def duration_nanos(start_time:, end_time:)
    ((end_time.to_f - start_time.to_f) * 1e9).to_i
  end
end
