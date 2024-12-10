# frozen_string_literal: true

# https://github.com/sinatra/sinatra-recipes/blob/main/asset_management/sinatra_assetpack.md

require APP_PATH

# %r{/(home)?}

class Base < App
  get '/' do
    erb :landingPage
  end
  get '/about' do
    erb :about
  end
  get '/ads' do
    erb :ads
  end
end
