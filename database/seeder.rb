# frozen_string_literal: true

require_relative '../config/environment'
require_relative './models/user'

User.drop
User.create
p User.primary_key_clause

User.insert(username: 'john')
