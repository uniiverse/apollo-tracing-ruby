# Changelog

The following are lists of the notable changes included with each release.
This is intended to help keep people informed about notable changes between
versions, as well as provide a rough history. Each item is prefixed with
one of the following labels: `Added`, `Changed`, `Deprecated`,
`Removed`, `Fixed`, `Security`. We also use [Semantic Versioning](http://semver.org)
to manage the versions of this gem so
that you can set version constraints properly.

#### [Unreleased](https://github.com/uniiverse/apollo-tracing-ruby/compare/v1.1.0...HEAD)

* WIP

#### [v1.1.0](https://github.com/uniiverse/apollo-tracing-ruby/compare/v1.0.0..v1.1.0) – 2017-10-25

* `Added`: Apollo Engine Proxy version [2017.10-408-g497e1410](https://www.apollographql.com/docs/engine/proxy-release-notes.html). ([#2](https://github.com/uniiverse/apollo-tracing-ruby/pull/2))

#### [v1.0.0](https://github.com/uniiverse/apollo-tracing-ruby/compare/v0.1.1...v1.0.0) – 2017-10-17

* `Changed`: the gem name from `graphql-tracing` to `apollo-tracing`.

```ruby
# Before:

Schema = GraphQL::Schema.define do
  use GraphQL::Tracing.new
end
```

```ruby
# After:

Schema = GraphQL::Schema.define do
  use ApolloTracing.new
end
```

#### [v0.1.1](https://github.com/uniiverse/apollo-tracing-ruby/compare/v0.1.0...v0.1.1) – 2017-10-17

* `Fixed`: naming conflicts with [graphql-ruby](https://github.com/rmosolgo/graphql-ruby/pull/996) by restricting the gem version.

#### [v0.1.0](https://github.com/uniiverse/apollo-tracing-ruby/compare/d346dd2...v0.1.0) – 2017-08-28

* `Added`: initial functional version.
