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
    @posts = Post.random_posts(daily_seed, 0, 10)

    p @posts
    p daily_seed

    erb :"posts/home"
  end
end
