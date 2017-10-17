# Apollo Tracing

[![Build Status](https://travis-ci.org/uniiverse/apollo-tracing-ruby.svg?branch=master)](https://travis-ci.org/uniiverse/apollo-tracing-ruby)

Ruby implementation of [GraphQL](https://github.com/rmosolgo/graphql-ruby) trace data in the [Apollo Tracing](https://github.com/apollographql/apollo-tracing) format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apollo-tracing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apollo-tracing

## Usage

Define a GraphQL schema:

```ruby
# Define a type
PostType = GraphQL::ObjectType.define do
  name "Post"

  field :id, !types.ID
  field :title, !types.String
end

# Define a query
QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :posts, !types[PostType] do
    argument :user_id, !types.ID
    resolve ->(obj, args, ctx) { Post.where(user_id: args[:user_id]) }
  end
end

# Define a schema
Schema = GraphQL::Schema.define do
  query QueryType
end

# Execute query
query = "query($user_id: ID!) {
          posts(user_id: $user_id) {
            id
            title
          }
        }"
Schema.execute(query, variables: { user_id: 1 })
```

### Setup Tracing

Add 'ApolloTracing' to your schema:

<pre>
Schema = GraphQL::Schema.define do
  query QueryType
  <b>use ApolloTracing.new</b>
end
</pre>

Now your response should look something like:
```
{
   "data":{
      "posts":[
         {
            "id":"1",
            "title":"Post Title"
         }
      ]
   },
   "extensions":{
      "tracing":{
         "version":1,
         "startTime":"2017-08-25T19:55:04.821Z",
         "endTime":"2017-08-25T19:55:04.823Z",
         "duration":1702785,
         "execution":{
            "resolvers":[
               {
                  "path":[
                     "posts"
                  ],
                  "parentType":"Query",
                  "fieldName":"posts",
                  "returnType":"[Post!]!",
                  "startOffset":1451015,
                  "duration":15735
               },
               {
                  "path":[
                     "posts",
                     0,
                     "id"
                  ],
                  "parentType":"Post",
                  "fieldName":"id",
                  "returnType":"ID!",
                  "startOffset":1556873,
                  "duration":6914
               },
               {
                  "path":[
                     "posts",
                     0,
                     "title"
                  ],
                  "parentType":"Post",
                  "fieldName":"title",
                  "returnType":"String!",
                  "startOffset":1604795,
                  "duration":4053
               },
               {
                  "path":[
                     "posts",
                     0,
                     "user_id"
                  ],
                  "parentType":"Post",
                  "fieldName":"user_id",
                  "returnType":"ID!",
                  "startOffset":1642942,
                  "duration":3814
               }
            ]
         }
      }
   }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/uniiverse/apollo-tracing-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

