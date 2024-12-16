# frozen_string_literal: true

require BASE_COMPONENT_PATH

class PostListComponent < BaseComponent
  def initialize(posts, user_id, next_offset = 0)
    super()
    @posts = posts
    @user_id = user_id
    @next_offset = next_offset
  end
end
