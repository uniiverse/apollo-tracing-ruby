require "spec_helper"

require 'fixtures/user'
require 'fixtures/post'
require 'fixtures/schema'

RSpec.describe ApolloTracing do
  describe '.start_proxy' do
    it 'runs a proxy' do
      pid = ApolloTracing.start_proxy('spec/fixtures/apollo-engine-proxy.json')
      expect { Process.getpgid(pid) }.not_to raise_error
      ApolloTracing.stop_proxy
    end

    it 'runs a proxy with a given JSON instead of a file path' do
      config_json = File.read('spec/fixtures/apollo-engine-proxy.json')
      pid = ApolloTracing.start_proxy(config_json)
      expect { Process.getpgid(pid) }.not_to raise_error
      ApolloTracing.stop_proxy
    end
  end

  describe '.stop_proxy' do
    it 'stops a proxy' do
      pid = ApolloTracing.start_proxy('spec/fixtures/apollo-engine-proxy.json')
      ApolloTracing.stop_proxy
      expect { Process.getpgid(pid) }.to raise_error(Errno::ESRCH, 'No such process')
    end
  end

  context 'introspection' do
    it 'returns time in RFC 3339 format' do
      query = "query($user_id: ID!) { posts(user_id: $user_id) { id title user_id } }"
      now = Time.new(2017, 8, 25, 0, 0, 0, '+00:00')
      allow(Time).to receive(:now).and_return(now)

      result = Schema.execute(query, variables: {'user_id' => "1"})

      expect(result.dig("extensions", 'tracing', 'startTime')).to eq('2017-08-25T00:00:00.000Z')
      expect(result.dig("extensions", 'tracing', 'endTime')).to eq('2017-08-25T00:00:00.000Z')
    end

    it "resolves graphql query with tracing extension" do
      query = "query($user_id: ID!) { posts(user_id: $user_id) { id title user_id } }"

      result = Schema.execute(query, variables: {'user_id' => "1"})

      expect(result["data"]).to eq(
        "posts" => [{
          "id" => "1",
          "title" => "Post Title",
          "user_id" => "1"
        }]
      )
      tracing = result.dig("extensions", 'tracing')

      expect(tracing['version']).to eq(1)
      expect(tracing['startTime']).to be_a(String)
      expect(tracing['endTime']).to be_a(String)
      expect(tracing['duration']).to be >= 0

      resolvers = tracing.dig('execution', 'resolvers')

      expect(resolvers.dig(0, 'path')).to eq(["posts"])
      expect(resolvers.dig(0, 'parentType')).to eq("Query")
      expect(resolvers.dig(0, 'fieldName')).to eq("posts")
      expect(resolvers.dig(0, 'returnType')).to eq("[Post!]!")
      expect(resolvers.dig(0, 'startOffset')).to be >= 0
      expect(resolvers.dig(0, 'duration')).to be >= 0

      expect(resolvers.dig(1, 'path')).to eq(["posts", 0, "id"])
      expect(resolvers.dig(1, 'parentType')).to eq("Post")
      expect(resolvers.dig(1, 'fieldName')).to eq("id")
      expect(resolvers.dig(1, 'returnType')).to eq("ID!")
      expect(resolvers.dig(1, 'startOffset')).to be >= 0
      expect(resolvers.dig(1, 'duration')).to be >= 0

      expect(resolvers.dig(2, 'path')).to eq(["posts", 0, "title"])
      expect(resolvers.dig(2, 'parentType')).to eq("Post")
      expect(resolvers.dig(2, 'fieldName')).to eq("title")
      expect(resolvers.dig(2, 'returnType')).to eq("String!")
      expect(resolvers.dig(2, 'startOffset')).to be >= 0
      expect(resolvers.dig(2, 'duration')).to be >= 0

      expect(resolvers.dig(3, 'path')).to eq(["posts", 0, "user_id"])
      expect(resolvers.dig(3, 'parentType')).to eq("Post")
      expect(resolvers.dig(3, 'fieldName')).to eq("user_id")
      expect(resolvers.dig(3, 'returnType')).to eq("ID!")
      expect(resolvers.dig(3, 'startOffset')).to be >= 0
      expect(resolvers.dig(3, 'duration')).to be >= 0
    end

    it "resolves without race conditions and multiple threads by sharing vars in the context" do
      thread1 = Thread.new do
        query1 = "query($user_id: ID!) { posts(user_id: $user_id) { id slow_id } }"
        @result1 = Schema.execute(query1, variables: {'user_id' => "1"})
      end

      thread2 = Thread.new do
        sleep 1
        query2 = "query($user_id: ID!) { posts(user_id: $user_id) { title } }"
        @result2 = Schema.execute(query2, variables: {'user_id' => "1"})
      end

      [thread1, thread2].map(&:join)

      expect(@result1.dig('extensions', 'tracing', 'execution', 'resolvers', 1, 'path')).to eq(['posts', 0, 'id'])
      expect(@result1.dig('extensions', 'tracing', 'execution', 'resolvers', 2, 'path')).to eq(['posts', 0, 'slow_id'])
      expect(@result2.dig('extensions', 'tracing', 'execution', 'resolvers', 1, 'path')).to eq(['posts', 0, 'title'])
    end
  end
end
