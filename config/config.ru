# frozen_string_literal: true

require 'rack'
require_relative 'environment'
require 'rack/attack'
require 'active_support/notifications'
require 'active_support/cache'

if false

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  # Configure Rack::Attack (e.g., limit to 100 requests per minute per IP)
  Rack::Attack.throttle('req/ip', limit: 100, period: 60) do |req|
    req.ip
  end

  # Optionally, you can customize the response when a limit is exceeded:
  Rack::Attack.blocklisted_responder = lambda do |env|
    [429, { 'Content-Type' => 'text/plain' }, ['Rate limit exceeded. Try again later.']]
  end
end

class RackApp
  attr_reader :app

  def initialize
    @app = Rack::Builder.app do
      use Rack::Attack

      Dir.glob(File.join(ROUTES_PATH, '/**/*.rb')).each do |route_file|
        next if File.basename(route_file) == 'app.rb'

        require route_file

        # Get the class name from the file name
        class_name = File.basename(route_file, '.rb').split('_').map(&:capitalize).join
        route_class = Object.const_get(class_name)

        # Derive the prefix from the file's folder structure relative to the routes folder
        relative_path = route_file.sub(ROUTES_PATH, '') # Remove base routes folder
        prefix = File.dirname(relative_path).gsub('\\', '/').sub(%r{^/}, '') # Normalize prefix

        # Automatically scope the routes in the file to the prefix
        scope_prefix = prefix.empty? ? '/' : "/#{prefix}"

        # Mount the route class at the prefix
        map(scope_prefix) do
          run route_class
        end
      end
    end
  end

  def call(env)
    app.call(env)
  end
end

run RackApp.new
