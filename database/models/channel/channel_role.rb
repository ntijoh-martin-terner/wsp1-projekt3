require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class ChannelRole < BaseModel
  def self.find_id_by_name_and_group(channel_id, name)
    result = db.execute('SELECT id FROM channel_roles WHERE channel_id = ? AND name = ? LIMIT 1', channel_id, name)
    result.first['id'] if result.any?
  end

  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      channel_id INTEGER REFERENCES channel(id),
      name TEXT NOT NULL,
      UNIQUE(channel_id, name) -- Ensure no duplicate role names within a group
    SQL
  end
end
