require "spec_helper"

require 'fixtures/user'
require 'fixtures/post'
require 'fixtures/schema'

RSpec.describe Graphql::Tracing do
  it "resolves graphql query with tracing extension" do
    query = "query($user_id: ID!) { posts(user_id: $user_id) { id title user_id } }"
    now = Time.new(2017, 8, 25)
    allow(Time).to receive(:now).and_return(now, now + 3)
    # allow(Time).to receive(:now).and_call_original
    # allow(Time).to receive(:now).and_return(now + 3)

    result = Schema.execute(query, variables: {'user_id' => "1"})

    expect(result["data"]).to eq(
      "posts" => [{
        "id" => "1",
        "title" => "Post Title",
        "user_id" => "1"
      }]
    )
    expect(result["extensions"]).to eq(
      "tracing" => {
        "version" => 1,
        "startTime" => "2017-08-25T04:00:00.000Z",
        "endTime" => "2017-08-25T04:00:03.000Z",
        "duration" => 3_000_000_000,
        # "execution" => {
        #   "resolvers" => [
        #     {
        #       "path" => [
        #         "posts"
        #       ],
        #       "parentType" => "Query",
        #       "fieldName" => "posts",
        #       "returnType" => "[Post!]!",
        #       "startOffset" => 1172456,
        #       "duration" => 215657
        #     },
        #     {
        #       "path" => [
        #         "posts",
        #         0,
        #         "id"
        #       ],
        #       "parentType" => "Query",
        #       "fieldName" => "id",
        #       "returnType" => "ID!",
        #       "startOffset" => 1903307,
        #       "duration" => 73098
        #     },
        #     {
        #       "path" => [
        #         "posts",
        #         0,
        #         "title"
        #       ],
        #       "parentType" => "Query",
        #       "fieldName" => "title",
        #       "returnType" => "String!",
        #       "startOffset" => 1903307,
        #       "duration" => 73098
        #     },
        #     {
        #       "path" => [
        #         "posts",
        #         0,
        #         "user_id"
        #       ],
        #       "parentType" => "Query",
        #       "fieldName" => "user_id",
        #       "returnType" => "ID!",
        #       "startOffset" => 1903307,
        #       "duration" => 73098
        #     }
        #   ]
        # }
      }
    )
  end
end
