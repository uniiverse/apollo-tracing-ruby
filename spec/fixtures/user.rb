# frozen_string_literal: true

class User
  attr_accessor :id, :role

  def initialize(id:, role:)
    self.id = id
    self.role = role
  end
end
