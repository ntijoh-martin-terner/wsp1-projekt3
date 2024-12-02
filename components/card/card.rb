# frozen_string_literal: true

require BASE_COMPONENT_PATH

class Card < BaseComponent
  def initialize(title)
    super()
    @title = title
  end
end
