# frozen_string_literal: true

require 'ostruct'

BadPostType = GraphQL::ObjectType.define do
  name 'Foo'
  description 'See also PostType, for a working version of this'

  field :id, !types.String, hash_key: :id
  field :user_id, !types.String, hash_key: :user_id
  field :title, !types.String # This is the intended broken-ness: missing a hash_key setting
end

BrokenQueryType = GraphQL::ObjectType.define do
  name 'BrokenQuery'
  description 'See also QueryType, for a working version of this'
  field :posts, !types[!BadPostType] do
    argument :user_id, !types.ID
    resolve ->(_obj, _args, _ctx) {
      [ { id: 'foo1', title: 'titel1', user_id: 'Sven'} ]
    }
  end
end

BrokenSchema = GraphQL::Schema.define do
  query BrokenQueryType
  use ApolloTracing.new
end
