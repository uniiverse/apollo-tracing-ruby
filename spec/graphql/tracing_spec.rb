require "spec_helper"

RSpec.describe Graphql::Tracing do
  it "has a version number" do
    expect(Graphql::Tracing::VERSION).to eq("0.1.0")
  end
end
