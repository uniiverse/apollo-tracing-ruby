# frozen_string_literal: true

require "graphql"
require "apollo_tracing/version"

class ApolloTracing
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
