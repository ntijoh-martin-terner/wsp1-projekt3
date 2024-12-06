# frozen_string_literal: true

# https://github.com/sinatra/sinatra-recipes/blob/main/asset_management/sinatra_assetpack.md

require APP_PATH

# %r{/(home)?}

class Landingpage < App
  get '/' do
    erb :landingPage
  end
end
