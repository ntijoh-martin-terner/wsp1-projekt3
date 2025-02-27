# frozen_string_literal: true

require BASE_COMPONENT_PATH

class PostListComponent < BaseComponent
  def initialize(posts: nil, user_id: nil, offset: 0, limit: 10, channel_ids: [], order_by: nil, search_query: nil,
                 user_ids: nil, base_url: nil)
    super()
    @posts = posts
    @user_id = user_id
    @channel_ids = channel_ids
    @search_query = search_query
    @user_ids = user_ids
    @limit = limit
    @order_by = order_by
    @next_offset = offset
    @base_url = base_url
  end
end
