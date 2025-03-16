# frozen_string_literal: true

require APP_PATH
require File.join(DATABASE_PATH, '/models/channel/channel.rb')
# require 'sinatra/json'
require 'digest'

#
# Api routes
#
class Api < App
  #
  # GET /channels/search
  #
  # Searches for channels based on a query parameter.
  #
  # @param [String] q The search query provided by the user.
  # @return [JSON] A JSON array of channels matching the search criteria.
  # @example Requesting a channel search
  #   GET /channels/search?q=music
  #   Response:
  #   [
  #     {
  #       "id": 1,
  #       "name": "Music Channel",
  #       "description": "A channel dedicated to music."
  #     },
  #     {
  #       "id": 2,
  #       "name": "Live Music Streams",
  #       "description": "24/7 live music streaming."
  #     }
  #   ]
  #
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
