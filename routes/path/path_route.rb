# frozen_string_literal: true

require APP_PATH

class Pathroute < App
  get '/' do
    erb :"second_layout/pathRoute"
  end
end
