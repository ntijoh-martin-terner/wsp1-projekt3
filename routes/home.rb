# frozen_string_literal: true

# https://github.com/sinatra/sinatra-recipes/blob/main/asset_management/sinatra_assetpack.md

require APP_PATH

class Home < App
  get '/' do
    erb :home
  end
end
