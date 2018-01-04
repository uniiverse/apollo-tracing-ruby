# frozen_string_literal: true

require 'fixtures/user'
require 'fixtures/lazy_user_name'
require 'fixtures/post'

PostType = GraphQL::ObjectType.define do
  name "Post"

  field :id, !types.ID
  field :title, !types.String
  field :user_id, !types.ID
  field :slow_id, !types.ID, resolve: ->(obj, _, _) do
    sleep 2
    obj.id
  end
end

UserType = GraphQL::ObjectType.define do
  name "User"

  field :id, !types.ID
  field :lazy_name, !types.String do
    resolve ->(obj, args, ctx) { LazyUserName.new(obj) }
  end
end

QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :posts, !types[!PostType] do
    argument :user_id, !types.ID
    resolve ->(obj, args, ctx) { Post.where(user_id: args[:user_id]) }
  end

  field :users, !types[!UserType] do
    resolve ->(obj, args, ctx) { User.all }
  end
end

Schema = GraphQL::Schema.define do
  query QueryType
  lazy_resolve LazyUserName, :sync

  use ApolloTracing.new
end
