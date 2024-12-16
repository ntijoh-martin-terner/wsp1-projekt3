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
    @posts = PostModel.random_posts(daily_seed, @offset, @limit)
    @user_id = session[:user_id]

    erb :"posts/home"
  end

  get '/more' do
    offset = params[:offset].to_i
    limit = 10
    posts = PostModel.random_posts(daily_seed, offset, limit)
    user_id = session[:user_id]

    next_offset = offset + limit

    if posts.empty?
      halt 204 # No Content
    end

    PostListComponent(posts, user_id, next_offset)

    # erb :'posts/partials/post_list', layout: false, find_layout: false
  end
end
