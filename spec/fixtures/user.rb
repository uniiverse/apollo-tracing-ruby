# frozen_string_literal: true

class User
  attr_accessor :id, :role

  def self.all
    [new(id: 1, role: 'User'), new(id: 2, role: 'Admin')]
  end

  def initialize(id:, role:)
    self.id = id
    self.role = role
  end

  def name
    "Name#{id}"
  end
end
