require "spec_helper"

require 'fixtures/user'
require 'fixtures/post'
require 'fixtures/schema'

RSpec.describe Graphql::Tracing do
  it "resolves graphql query" do
    query = "query($user_id: ID!) { posts(user_id: $user_id) { id title user_id } }"
    result = Schema.execute(query, variables: {'user_id' => "1"})

    expect(result).to eq({"data" => {"posts" => [{"id" => "1", "title" => "Post Title", "user_id" => "1"}]}})
  end
end
