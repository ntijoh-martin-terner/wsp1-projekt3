# frozen_string_literal: true

require APP_PATH
require File.join(DATABASE_PATH, '/models/channel/channel.rb')
# require 'sinatra/json'
require 'digest'

class Api < App
  get '/channels/search' do
    query = params[:q].strip
    halt 400 if query.empty?

    channels = ChannelModel.search_channels(search: query)

    p 'found channels:'
    p channels

    content_type :json
    channels.to_json
  end
end
