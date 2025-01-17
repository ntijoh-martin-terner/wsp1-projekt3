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

class Home < App
  before do
    redirect '/404' if session[:user_id].nil?
  end

  get '/home' do
    @limit = 10
    @offset = 0
    @posts = PostModel.retrieve_posts(seed: daily_seed, offset: @offset, limit: @limit, random_order: true)
    @user_id = session[:user_id]

    erb :"posts/home"
  end

  get '/' do
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

    @limit = 20
    @offset = 0
    @order = 'created_at_desc'
    @user_id = session[:user_id]
    @channel_ids = []
    @posts = PostModel.retrieve_posts(offset: @offset, limit: @limit, channel_ids: [],
                                      search_query: @search_query, order_by: @order_by)

    erb :'posts/home'
  end

  get '/more' do
    offset = params[:offset].to_i || 0
    limit = params[:limit].to_i || 10
    order_by = params[:order_by] || nil
    search_query = params[:search_query] || nil
    channel_ids = params[:channel_ids] || []
    order = params[:order]
    posts = PostModel.retrieve_posts(seed: daily_seed, offset: offset, limit: limit, channel_ids: channel_ids,
                                     order_by: order_by, search_query: search_query, random_order: true)
    user_id = session[:user_id]

    next_offset = offset + limit

    if posts.empty?
      halt 204 # No Content
    end

    PostListComponent(posts: posts, user_id: user_id, offset: next_offset, limit: limit, channel_ids: channel_ids,
                      order: order)

    # erb :'posts/partials/post_list', layout: false, find_layout: false
  end
end
