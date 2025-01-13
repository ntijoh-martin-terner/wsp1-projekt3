# frozen_string_literal: true

require BASE_COMPONENT_PATH

class PostListComponent < BaseComponent
  def initialize(posts: nil, user_id: nil, offset: 0, limit: 10, channel_ids: [], order_by: nil, search_query: nil)
    super()
    @posts = posts
    @user_id = user_id
    @channel_ids = channel_ids
    @search_query = search_query
    @limit = limit
    @order_by = order_by
    @next_offset = offset
  end
end
