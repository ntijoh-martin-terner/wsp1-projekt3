# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/url_for'
require 'better_errors'
require 'rdiscount'
require 'erb'
require 'dotenv/load'
require_relative '../lib/asset_bundler'
# require_relative '../lib/middleware/input_sanitizer'

def sanitize_params!(params)
  # p params
  # p 'sanitizing  ^^^'

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

class App < Sinatra::Base
  configure do
    set :root, APP_ROOT
    set :views, VIEWS_PATH
    set :components, COMPONENTS_PATH
    set :public_folder, PUBLIC_PATH
    set :asset_bundler, AssetBundler.new
    enable :sessions
    # use InputSanitizer
    set :session_secret, ENV['SESSION_SECRET'] # Change this to a secure secret

    # JavaScript group
    settings.asset_bundler.add_js(:flowbite, paths: [
                                    [File.join(APP_ROOT, 'node_modules/flowbite/dist/flowbite.min.js'), false]
                                  ])
    settings.asset_bundler.add_js(:flowbite_module, paths: [
                                    [File.join(APP_ROOT, 'node_modules/flowbite/dist/flowbite.esm.js'), false]
                                  ])
    settings.asset_bundler.add_js(:htmx, paths: [
                                    [File.join(APP_ROOT, 'assets/js/htmx.min.js'), false]
                                  ])
    settings.asset_bundler.add_js(:post, paths: [
                                    [File.join(APP_ROOT, 'assets/js/htmx.min.js'), false],
                                    [File.join(APP_ROOT, 'node_modules/flowbite/dist/flowbite.min.js'), false],
                                    [File.join(APP_ROOT, 'assets/js/voteComponent.js'), true],
                                    [File.join(APP_ROOT, 'assets/js/postMisc.js'), true],
                                    [File.join(APP_ROOT, 'assets/js/share.js'), true]
                                  ])
    settings.asset_bundler.add_js(:post_modules, paths: [
                                    [File.join(APP_ROOT, 'assets/js/shareModule.js'), true]
                                  ])

    # CSS group
    settings.asset_bundler.add_css(:application, paths: [
                                     [File.join(APP_ROOT, 'assets/builds/application.css'), false]
                                   ])
  end

  not_found do
    erb :"/error/404"
  end

  before do
    @logged_in = !session[:user_id].nil?
    @user = UserModel.find_by_id(id: session[:user_id]) if @logged_in
    sanitize_params!(params) unless params.empty?
  end

  # Serve JavaScript bundles dynamically
  get '/assets/:group.js' do |group|
    bundler = settings.asset_bundler
    content_type 'application/javascript'
    bundler.bundle_js(group.to_sym)
  end

  # Serve JavaScript bundles dynamically
  get '/assets/:group.css' do |group|
    bundler = settings.asset_bundler
    content_type 'text/css'
    bundler.bundle_css(group.to_sym)
  end

  # Just in development!
  configure :development do
    use BetterErrors::Middleware
    # you need to set the application root in order to abbreviate filenames
    # within the application:
    BetterErrors.application_root = APP_ROOT
  end

  helpers Sinatra::UrlForHelper

  # Override the `erb` method to include custom layout lookup
  def erb(template, options = {}, locals = {})
    # Find the layout file, if any

    view_path = File.join(settings.views, "#{template}.erb")

    layout_file = find_layout_file(view_path)

    # Include the layout in options if it exists
    options[:layout] = layout_file ? File.read(layout_file) : false unless options[:find_layout] == false

    # Call the original `erb` method with updated options
    super(template, options, locals)
  end

  private

  # Finds a `layout.erb` file starting from the current directory up to `/routes/`
  def find_layout_file(start_path)
    current_path = File.dirname(start_path)

    until [ROUTES_PATH, '/'].include?(current_path)
      layout_path = File.join(current_path, 'layout.erb')

      return layout_path if File.exist?(layout_path)

      current_path = File.dirname(current_path) # Move up one level
    end

    nil # No layout found
  end

  # Helper for dynamically loading components
  helpers do
    @helpers = []

    # Dynamically load and define methods for components
    Dir.glob(File.join(settings.components, '/*/*.rb')).each do |component|
      # Require the component file
      require component

      # Get the class name by capitalizing the file's base name
      class_name = File.basename(component, '.rb').split('_').map(&:capitalize).join

      # Dynamically define a helper method for the component
      @helpers << define_method(class_name.to_sym) do |*args, **kwargs|
        # Instantiate the component with provided arguments
        component_class = Object.const_get(class_name)

        component_instance =
          if kwargs.any?
            component_class.new(**kwargs)
          else
            component_class.new(*args)
          end

        # Render the component's ERB template
        component_instance.render
      end

      BaseComponent.define_method(class_name.to_sym) do |*args, **kwargs|
        # Instantiate the component with provided arguments
        component_class = Object.const_get(class_name)

        # p 'DWPDWKDOKPOKWPDOKWODOWSKWKODKWW'
        # p args
        # p kwargs
        # p(*args)
        # p(**kwargs)

        # Handle positional and keyword arguments
        component_instance =
          if kwargs.any?
            component_class.new(**kwargs)
          else
            component_class.new(*args)
          end

        # component_instance = component_class.new(*args)

        # Render the component's ERB template
        component_instance.render
      end
    end

    # BaseComponent.include_helpers!(@helpers, self)
  end

  # Defer including helpers until the app instance is initialized
  # configure do
  #   BaseComponent.include_helpers!(@helpers, self)
  # end

  # BaseComponent.include_helpers!(@helpers, self)
end
