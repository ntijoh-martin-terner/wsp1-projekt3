require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class ChannelModel < BaseModel
  def self.get_channel_from_id(channel_id)
    db.execute(<<-SQL, [channel_id]).first
    SELECT *
    FROM channel
    WHERE id = ?
    SQL
  end

  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE, -- Name of the group
      description TEXT, -- Description of the group
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Group creation timestamp
    SQL
  end
end
