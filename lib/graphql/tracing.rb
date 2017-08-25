# frozen_string_literal: true

require "graphql"
require "graphql/tracing/version"

module GraphQL
  class Tracing
    def use(schema_definition)
      schema_definition.instrument(:query, self)
    end

    def before_query(query)
      @start_time = Time.now.utc
    end

    def after_query(query)
      result = query.result
      end_time = Time.now.utc
      duration_nanos = ((end_time.to_f - @start_time.to_f) * 1e9).to_i

      result["extensions"] ||= {}
      result["extensions"]["tracing"] = {
        "version" => 1,
        "startTime" => @start_time.strftime('%FT%T.%3NZ'),
        "endTime" => end_time.strftime('%FT%T.%3NZ'),
        "duration" => duration_nanos
      }
    end
  end
end
