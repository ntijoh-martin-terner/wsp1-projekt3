# frozen_string_literal: true

# https://github.com/sinatra/sinatra-recipes/blob/main/asset_management/sinatra_assetpack.md

require APP_PATH

require File.join(DATABASE_PATH, '/models/user.rb')

# %r{/(home)?}

class Account < App
  get '/:user_id/settings' do |user_id|
    @account_user = UserModel.find_by_id(id: user_id.to_i)
    @user_id = user_id.to_i
    @path_info = request.fullpath
    @account_user_name = @account_user['username']

    redirect "account/#{user_id}/posts" if session[:user_id] != user_id.to_i

    erb :"account/user/settings"
  end

  # Redirect /:user_id/posts to /:user_id/posts/new
  get '/:user_id/posts' do |user_id|
    redirect "/account/#{user_id}/posts/random"
  end

  get '/:user_id' do |user_id|
    redirect "/account/#{user_id}/posts/random"
  end

  get '/:user_id/posts/?*' do |user_id, sorting|
    @account_user = UserModel.find_by_id(id: user_id.to_i)
    halt 404 unless @account_user # Handle user not found

    @path_info = request.fullpath
    @account_user_name = @account_user['username']
    @user_id = user_id.to_i
    @current_account = session[:user_id].to_i == @user_id

    @limit = 10
    @offset = 0
    @user_ids = [@user_id]

    # Define sorting options
    case sorting
    when 'new', nil
      order_by = 'recent'
      random_order = false
    when 'hot'
      order_by = 'upvotes'
      random_order = false
    when 'rising'
      order_by = 'votes'
      random_order = false
    when 'random'
      order_by = nil
      random_order = true
    else
      halt 404 # Return 404 for unknown sorting types
    end

    # Special handling for random sorting
    seed = sorting == 'random' ? rand(25_000) : nil

    @posts = PostModel.retrieve_posts(
      offset: @offset,
      limit: @limit,
      user_ids: @user_ids,
      order_by: order_by,
      random_order: random_order,
      seed: seed
    )

    erb :"account/user/posts"
  end

  get '/login' do
    erb :"account/login"
  end

  get '/signup' do
    erb :"account/signup"
  end

  post '/logout' do
    session[:user_id] = nil
    redirect back
  end

  post '/login' do
    username = params['username']
    password = params['password']

    matching_user = UserModel.find_by_username(username: username)

    if matching_user.nil? || !UserModel.valid_password?(password, matching_user['password_hash'])
      status 404
      redirect back
    end

    session[:user_id] = matching_user['id']
    redirect '/posts/home'
  end
end
