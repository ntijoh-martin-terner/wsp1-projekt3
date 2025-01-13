# frozen_string_literal: true

require BASE_COMPONENT_PATH

class PostFilteringComponent < BaseComponent
  def initialize(params, post_path)
    @params = params
    @post_path = post_path
    super()
  end
end
