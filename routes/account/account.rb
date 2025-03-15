# frozen_string_literal: true

# https://github.com/sinatra/sinatra-recipes/blob/main/asset_management/sinatra_assetpack.md

require APP_PATH

require File.join(DATABASE_PATH, '/models/user.rb')

# %r{/(home)?}

#
# Account routes
#
class Account < App
  #
  # GET /:user_id/settings
  #
  # Displays the settings page for a user.
  #
  # @param user_id [String] the ID of the user (as a path variable)
  # @return [String] the rendered ERB template for the account user settings page
  # @example
  #   GET /123/settings
  get '/:user_id/settings' do |user_id|
    @account_user = UserModel.find_by_id(id: user_id.to_i)
    @user_id = user_id.to_i
    @path_info = request.fullpath
    @account_user_name = @account_user['username']
    @created_at = @account_user['created_at']

    redirect "account/#{user_id}/posts" if session[:user_id] != user_id.to_i

    erb :"account/user/settings"
  end

  #
  # GET /:user_id/posts
  #
  # Redirects the user to the random posts route.
  #
  # @param user_id [String] the ID of the user (as a path variable)
  # @return [Array] a Rack redirection response to /account/:user_id/posts/random
  # @example
  #   GET /123/posts
  get '/:user_id/posts' do |user_id|
    redirect "/account/#{user_id}/posts/random"
  end

  #
  # GET /:user_id/posts/?*
  #
  # Retrieves and displays posts for the specified user with sorting.
  #
  # @param user_id [String] the ID of the user (as a path variable)
  # @param sorting [String] the sorting parameter ('new', 'hot', 'controversial', 'random')
  # @return [String] the rendered ERB template for the account user posts page
  # @example
  #   GET /123/posts/new
  get '/:user_id/posts/?*' do |user_id, sorting|
    @account_user = UserModel.find_by_id(id: user_id.to_i)
    halt 404 unless @account_user # Handle user not found

    @path_info = request.fullpath
    @account_user_name = @account_user['username']
    @user_id = user_id.to_i
    @current_account = session[:user_id].to_i == @user_id
    @created_at = @account_user['created_at']

    @limit = 10
    @offset = 0
    @user_ids = [@user_id]

    @order_by = case sorting
                when 'new' then 'post.created_at DESC'
                when 'hot' then 'post.created_at ASC'
                when 'controversial' then 'downvotes DESC'
                end

    @random_order = true if sorting == 'random'

    # Special handling for random sorting
    @seed = @random_order ? rand(25_000) : nil

    @posts = PostModel.retrieve_posts(
      offset: @offset,
      limit: @limit,
      user_ids: @user_ids,
      order_by: @order_by,
      random_order: @random_order,
      seed: @seed
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

  get '/:user_id' do |user_id|
    redirect "/account/#{user_id}/posts/random"
  end
end
