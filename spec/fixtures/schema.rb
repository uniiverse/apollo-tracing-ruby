# frozen_string_literal: true

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

QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :posts, !types[!PostType] do
    argument :user_id, !types.ID
    resolve ->(obj, args, ctx) { Post.where(user_id: args[:user_id]) }
  end
end

Schema = GraphQL::Schema.define do
  query QueryType
  use GraphQL::Tracing.new
end
