# frozen_string_literal: true

# https://github.com/sinatra/sinatra-recipes/blob/main/asset_management/sinatra_assetpack.md

require APP_PATH

# %r{/(home)?}

#
# Base routes
#
class Base < App
  #
  # GET /
  #
  # Renders the landing page.
  #
  # @example
  #   GET /
  #
  get '/' do
    erb :landingPage
  end

  #
  # GET /about
  #
  # Renders the about page.
  #
  # @example
  #   GET /about
  #
  get '/about' do
    erb :about
  end

  #
  # GET /ads
  #
  # Renders the ads page.
  #
  # @example
  #   GET /ads
  #
  get '/ads' do
    erb :ads
  end
end
