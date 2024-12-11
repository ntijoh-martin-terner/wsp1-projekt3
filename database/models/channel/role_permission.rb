require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class RolePermission < BaseModel
  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      channel_role_id INTEGER REFERENCES channel_role(id),
      permission_id INTEGER REFERENCES permission(id),
      UNIQUE(channel_role_id, permission_id) -- Prevent duplicate permissions for a role
    SQL
  end
end
