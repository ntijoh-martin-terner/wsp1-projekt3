require 'sanitize'

class InputSanitizer
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    sanitize_params!(req.params)
    @app.call(env)
  end

  private

  def sanitize_params!(params)
    p params
    p 'sanitizing  ^^^'

    params.each do |key, value|
      if value.is_a?(String)
        params[key] = Sanitize.fragment(value)
      elsif value.is_a?(Hash)
        sanitize_params!(value)
      elsif value.is_a?(Array)
        value.each_with_index do |item, index|
          if item.is_a?(String)
            value[index] = Sanitize.fragment(item)
          elsif item.is_a?(Hash)
            sanitize_params!(item)
          end
        end
      end
    end
  end
end
