# frozen_string_literal: true

require 'bundler/setup'

APP_ROOT = File.expand_path('..', __dir__)
PROJECT_NAME = 'red'
CONFIG_PATH = File.join(APP_ROOT, 'config')
APP_PATH = File.join(CONFIG_PATH, 'app.rb')
BASE_COMPONENT_PATH = File.join(CONFIG_PATH, 'base_component.rb')
ROUTES_PATH = File.join(APP_ROOT, 'routes')
COMPONENTS_PATH = File.join(APP_ROOT, 'components')
VIEWS_PATH = File.join(APP_ROOT, 'views')
ASSETS_PATH = File.join(APP_ROOT, 'assets')
PUBLIC_PATH = File.join(APP_ROOT, 'public')
DATABASE_PATH = File.join(APP_ROOT, 'database')
BASE_MODEL_PATH = File.join(DATABASE_PATH, 'base_model.rb')
DATABASE_FILE_PATH = File.join(DATABASE_PATH, "#{PROJECT_NAME}.sqlite")

# Load environment-specific setup, libraries, or gems
Bundler.require

# Additional common setup can go here
