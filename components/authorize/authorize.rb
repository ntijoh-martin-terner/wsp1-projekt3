# frozen_string_literal: true

require BASE_COMPONENT_PATH

class Authorize < BaseComponent
  def initialize(logged_in = false)
    super()
    @logged_in = logged_in
  end
end
