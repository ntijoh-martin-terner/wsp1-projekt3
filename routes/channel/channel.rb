require APP_PATH

require File.join(DATABASE_PATH, '/models/channel/channel.rb')
require File.join(DATABASE_PATH, '/models/user.rb')

class Channel < App
  get '/:channel_id' do |channel_id|
    redirect "/channel/#{channel_id}/random"
    # channel = ChannelModel.get_channel_from_id(channel_id)
    # # Handle sorting

    # @order_by = case params[:sort]
    #             when 'recent' then 'post.created_at DESC'
    #             when 'old' then 'post.created_at ASC'
    #             when 'upvotes' then 'upvotes DESC'
    #             when 'votes' then 'votes DESC'
    #             when 'downvotes' then 'downvotes DESC'
    #             else 'post.created_at DESC'
    #             end

    # # Handle search
    # @search_query = params[:search] || nil

    # @channel_id = channel_id
    # @name = channel['name']
    # @description = channel['description']
    # @created_at = channel['created_at']
    # @limit = 20
    # @offset = 0
    # @channel_ids = [channel_id.to_i]
    # @posts = PostModel.retrieve_posts(offset: @offset, limit: @limit, channel_ids: [channel_id.to_i],
    #                                   search_query: @search_query, order_by: @order_by)
    # erb :'posts/channel'
  end

  get %r{/([^/]+)/(new|hot|controversial|random)} do |channel_id, sorting|
    channel = ChannelModel.get_channel_from_id(channel_id)

    halt 404 unless channel

    @limit = 10
    @offset = 0

    @order_by = case sorting
                when 'new' then 'post.created_at DESC'
                when 'hot' then 'post.created_at ASC'
                when 'controversial' then 'downvotes DESC'
                end

    # @order_by = case params[:sort]
    #             when 'recent' then 'post.created_at DESC'
    #             when 'old' then 'post.created_at ASC'
    #             when 'upvotes' then 'upvotes DESC'
    #             when 'votes' then 'votes DESC'
    #             when 'downvotes' then 'downvotes DESC'
    #             else @order_by
    #             end

    @random_order = true if sorting == 'random'

    # Special handling for random sorting
    @seed = @random_order ? rand(25_000) : nil

    @channel_ids = [channel_id.to_i]

    @search_query = params[:search] || nil

    @channel_id = channel_id
    @name = channel['name']
    @description = channel['description']
    @created_at = channel['created_at']

    @posts = PostModel.retrieve_posts(
      offset: @offset,
      limit: @limit,
      order_by: @order_by,
      channel_ids: @channel_ids,
      search_query: @search_query,
      random_order: @random_order,
      seed: @seed
    )

    erb :"posts/channel"
  end
end
