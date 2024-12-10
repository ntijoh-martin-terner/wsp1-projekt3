# frozen_string_literal: true

# https://github.com/sinatra/sinatra-recipes/blob/main/asset_management/sinatra_assetpack.md

require APP_PATH

require File.join(DATABASE_PATH, '/models/user.rb')

# %r{/(home)?}

class Authorization < App
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

    matching_user = User.find_by_username(username)

    if matching_user.nil? || !User.valid_password?(password, matching_user['password_hash'])
      status 404
      redirect back
    end

    session[:user_id] = matching_user['id']
    redirect '/posts/home'
  end
end
