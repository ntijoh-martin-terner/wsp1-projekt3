# frozen_string_literal: true

require APP_PATH

class Home < App
  get '/home' do
    erb :"posts/home"
  end
end
