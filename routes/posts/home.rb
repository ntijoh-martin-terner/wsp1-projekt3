# frozen_string_literal: true

require APP_PATH

class Home < App
  before do
    if session[:user_id].nil?
      redirect '/404'
    end
  end

  get '/home' do
    erb :"posts/home"
  end
end
