require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class Permission < BaseModel
  def self.find_id_by_name(name)
    result = db.execute("SELECT id FROM #{table_name} WHERE name = ? LIMIT 1", name)
    result.first['id'] if result.any?
  end

  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE
    SQL
  end
end
