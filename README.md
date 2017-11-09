# Apollo Tracing

[![Build Status](https://travis-ci.org/uniiverse/apollo-tracing-ruby.svg?branch=master)](https://travis-ci.org/uniiverse/apollo-tracing-ruby)
[![Latest Version](https://img.shields.io/gem/v/apollo-tracing.svg)](https://rubygems.org/gems/apollo-tracing)

Ruby implementation of [GraphQL](https://github.com/rmosolgo/graphql-ruby) trace data in the [Apollo Tracing](https://github.com/apollographql/apollo-tracing) format.


## Contents

* [Installation](#installation)
* [Usage](#usage)
  * [Tracing](#tracing)
  * [Engine Proxy](#engine-proxy)
* [Development](#development)
* [Contributing](#contributing)
* [License](#license)

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
query = "
  query($user_id: ID!) {
    posts(user_id: $user_id) {
      id
      title
    }
  }
"
Schema.execute(query, variables: { user_id: 1 })
```

### Tracing

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

### Engine Proxy

Now you can start using the [Apollo Engine](https://www.apollographql.com/engine/) service.
Here is the general architecture overview of a sidecar mode – Proxy runs next to your application server:

```
 -----------------    request     -----------------    request     -----------------
|                 | -----------> |                 | -----------> |                 |
|     Client      |              |  Engine Proxy   |              |   Application   |
|                 | <----------- |                 | <----------- |                 |
 -----------------    response    -----------------    response    -----------------
                                          |
                                          |
                          GraphQL tracing | from response
                                          |
                                          ˅
                                  -----------------
                                 |                 |
                                 |  Apollo Engine  |
                                 |                 |
                                  -----------------
```

`ApolloTracing` gem comes with the [Apollo Engine Proxy](https://www.apollographql.com/docs/engine/index.html#engine-proxy) binary written in Go.
To configure the Proxy create a Proxy config file:

```
# config/apollo-engine-proxy.json

{
  "apiKey": "service:YOUR_ENGINE_API_KEY",
  "logging": { "level": "INFO" },
  "origins": [{
    "http": { "url": "http://localhost:3000/graphql" }
  }],
  "frontends": [{
    "host": "localhost", "port": 3001, "endpoint": "/graphql"
  }]
}
```

* `apiKey` – get this on your [Apollo Engine](https://engine.apollographql.com/) home page.
* `logging.level` – a log level for the Proxy ("INFO", "DEBUG" or "ERROR").
* `origins` – a list of URLs with your GraphQL endpoints in the Application.
* `frontends` – an address on which the Proxy will be listening.

To run the Proxy as a child process, which will be automatically terminated if the Application proccess stoped, add the following line to the `config.ru` file:

<pre>
# config.ru – this file is used by Rack-based servers to start the application
require File.expand_path('../config/environment',  __FILE__)

<b>ApolloTracing.start_proxy('config/apollo-engine-proxy.json')</b>
# or pass a JSON string:
# ApolloTracing.start_proxy('{"apiKey": "KEY", ...}')

run Your::Application
</pre>

For example, if you use [rails](https://github.com/rails/rails) with [puma](https://github.com/puma/puma) application server and run it like:

```
bundle exec puma -w 2 -t 16 -p 3000
```

The proccess tree may look like:

```
                ---------------
               |  Puma Master  |
               |   Port 3000   |
                ---------------
                   |      |
         ----------        ----------
        |                            |    ----------------
        ˅                             -> |  Puma Worker1  |
 ----------------                    |    -----------------
|  Engine Proxy  |                   |    ----------------
|   Port 3001    |                    -> |  Puma Worker2  |
 ----------------                         ----------------
```

Now you can send requests to the reverse Proxy `http://localhost:3001`.
It'll proxy any (GraphQL and non-GraphQL) requests to the Application `http://localhost:3000`.
If the request matches the endpoints described in `origins`, it'll strip the `tracing` data from the response and will send it to the Apollo Engine service.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/uniiverse/apollo-tracing-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
