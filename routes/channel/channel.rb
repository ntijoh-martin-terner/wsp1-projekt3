require APP_PATH

require File.join(DATABASE_PATH, '/models/channel/channel.rb')
require File.join(DATABASE_PATH, '/models/user.rb')

class Channel < App
  get '/:channel_id' do |channel_id|
    channel = ChannelModel.get_channel_from_id(channel_id)
    # Handle sorting

    @order_by = case params[:sort]
                when 'recent' then 'post.created_at DESC'
                when 'old' then 'post.created_at ASC'
                when 'upvotes' then 'upvotes DESC'
                when 'votes' then 'votes DESC'
                when 'downvotes' then 'downvotes DESC'
                else 'post.created_at DESC'
                end

    # Handle search
    @search_query = params[:search] || nil

    @channel_id = channel_id
    @name = channel['name']
    @description = channel['description']
    @created_at = channel['created_at']
    @limit = 20
    @offset = 0
    @order = 'created_at_desc'
    @channel_ids = [channel_id.to_i]
    @posts = PostModel.retrieve_posts(offset: @offset, limit: @limit, channel_ids: [channel_id.to_i],
                                      search_query: @search_query, order_by: @order_by)
    erb :'posts/channel'
  end
end
