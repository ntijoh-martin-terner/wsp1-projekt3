# frozen_string_literal: true

require APP_PATH
require File.join(DATABASE_PATH, '/models/post.rb')
require 'digest'

def daily_seed
  # Use the current date (e.g., "2024-12-11")
  current_date = Date.today.to_s
  # Generate a hash from the date and convert it to an integer
  Digest::SHA256.hexdigest(current_date).to_i(16) % (2**31 - 1)
end

class Posts < App
  before do
    redirect '/404' if session[:user_id].nil?
  end

  get '/home' do
    redirect '/posts/random'
  end

  get %r{/(new|hot|controversial|random)} do |sorting|
    @path_info = request.fullpath
    @user_id = session[:user_id].to_i

    @limit = 10
    @offset = 0

    @order_by = case sorting
                when 'new' then 'post.created_at DESC'
                when 'hot' then 'upvotes DESC'
                when 'controversial' then 'downvotes DESC'
                when 'random' then nil
                else halt 404
                end

    @search_query = params[:search] || nil

    p @search_query
    p 'SEARCH QUEEERY'

    @random_order = true if sorting == 'random'

    # Special handling for random sorting
    @seed = @random_order ? rand(25_000) : nil

    @posts = PostModel.retrieve_posts(
      offset: @offset,
      limit: @limit,
      order_by: @order_by,
      random_order: @random_order,
      search_query: @search_query,
      seed: @seed
    )

    erb :"posts/posts"
  end

  # get '/new' do
  #   @path_info = request.fullpath
  #   @limit = 10
  #   @offset = 0
  #   @posts = PostModel.retrieve_posts(offset: @offset, limit: @limit, random_order: false,
  #                                     order_by: 'recent')

  #   erb :"posts/posts"
  # end

  # get '/hot' do
  #   @path_info = request.fullpath
  #   @limit = 10
  #   @offset = 0
  #   @posts = PostModel.retrieve_posts(offset: @offset, limit: @limit, random_order: false,
  #                                     order_by: 'upvotes')

  #   erb :"posts/posts"
  # end

  # get '/rising' do
  #   @path_info = request.fullpath
  #   @limit = 10
  #   @offset = 0
  #   @posts = PostModel.retrieve_posts(offset: @offset, limit: @limit, random_order: false,
  #                                     order_by: 'votes')

  #   erb :"posts/posts"
  # end

  # get '/random' do
  #   @path_info = request.fullpath
  #   seed = rand(25_000)

  #   @posts = PostModel.retrieve_posts(seed: seed, offset: @offset, limit: @limit, random_order: true)

  #   erb :"posts/posts"
  # end

  # get '/test' do
  #   # @path_info = request.fullpath
  #   @limit = 10
  #   @offset = 0
  #   @channel_ids = []
  #   @posts = PostModel.retrieve_posts(seed: daily_seed, offset: @offset, limit: @limit, random_order: true)
  #   @user_id = session[:user_id]

  #   erb :"posts/posts"
  # end

  get '/' do
    redirect '/posts/random' if params.nil?

    # @order_by = case params[:sort]
    #             when 'recent' then 'post.created_at DESC'
    #             when 'old' then 'post.created_at ASC'
    #             when 'upvotes' then 'upvotes DESC'
    #             when 'votes' then 'votes DESC'
    #             when 'downvotes' then 'downvotes DESC'
    #             else 'post.created_at DESC'
    #             end

    @order_by = params[:order_by] || nil

    p 'order by:'
    p @order_by

    # Handle search
    @search_query = params[:search] || nil

    @random_order = params[:random_order] == 'true' || false

    # p @search_query
    # p '??? *^^'

    # @path_info = request.fullpath
    @limit = 20
    @offset = 0
    # @order = 'created_at_desc'
    @user_id = session[:user_id]
    @channel_ids = []
    @user_ids = []
    @posts = PostModel.retrieve_posts(offset: @offset, limit: @limit, channel_ids: @channel_ids,
                                      search_query: @search_query, order_by: @order_by,
                                      random_order: @random_order)

    erb :'posts/posts'
  end

  get '/more' do
    offset = params[:offset].to_i || 0
    limit = params[:limit].to_i || 10
    order_by = params[:order_by] || 'post.created_at DESC'
    search_query = params[:search_query] || nil
    channel_ids = params[:channel_ids] || []
    user_ids = params[:user_ids] || []
    random_order = params[:random_order] == 'true' || false

    p 'order by:'
    p order_by
    p random_order

    # order = params[:order]
    # order_by = case params[:sort]
    #            when 'recent' then 'post.created_at DESC'
    #            when 'old' then 'post.created_at ASC'
    #            when 'upvotes' then 'upvotes DESC'
    #            when 'votes' then 'votes DESC'
    #            when 'downvotes' then 'downvotes DESC'
    #            else 'post.created_at DESC'
    #            end
    posts = PostModel.retrieve_posts(seed: daily_seed, offset: offset, limit: limit, user_ids: user_ids,
                                     channel_ids: channel_ids, order_by: order_by,
                                     search_query: search_query, random_order: random_order)
    user_id = session[:user_id]

    next_offset = offset + limit

    if posts.empty?
      halt 204 # No Content
    end

    PostListComponent(posts: posts, user_id: user_id, offset: next_offset, limit: limit, channel_ids: channel_ids,
                      order_by: order_by, search_query: search_query, user_ids: user_ids, base_url: request.base_url,
                      random_order: random_order)

    # erb :'posts/partials/post_list', layout: false, find_layout: false
  end
end
