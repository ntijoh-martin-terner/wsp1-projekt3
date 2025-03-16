# frozen_string_literal: true

require APP_PATH
require 'rqrcode'

#
# Qr routes
#
class Qr < App
  before do
    redirect '/404' if session[:user_id].nil?
  end

  # GET /:post_id
  #
  # Retrieves a qr code image of the url of the post.
  #
  # @example
  #   GET /qr/123
  #
  get '/:post_id' do |post_id|
    qr = RQRCode::QRCode.new("#{request.base_url}/post/#{post_id}")

    content_type 'image/png'
    qr.as_png(size: 200, border_modules: 0).to_s
  end
end
