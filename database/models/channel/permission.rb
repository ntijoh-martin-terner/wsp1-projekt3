require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class PermissionModel < BaseModel
  def self.find_id_by_name(name: nil)
    result = db.execute("SELECT id FROM #{table_name} WHERE name = ? LIMIT 1", name)
    result.first['id'] if result.any?
  end

  def self.get_all_permissions
    db.execute(<<-SQL)
      SELECT name FROM permission
    SQL
  end

  def self.get_all_removeable_permissions
    db.execute(<<-SQL)
      SELECT name FROM permission
      WHERE removeable = 1
    SQL
  end

  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      removeable BOOLEAN NOT NULL DEFAULT 1
    SQL
  end
end
