require BASE_MODEL_PATH

class User < BaseModel
  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      username TEXT UNIQUE NOT NULL CHECK (LENGTH(username) >= 3 AND LENGTH(username) <= 20)
    SQL
  end
end
