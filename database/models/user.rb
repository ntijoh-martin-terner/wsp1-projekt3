require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class User < BaseModel
  def self.hash_password(password)
    BCrypt::Password.create(password)
  end

  def self.valid_password?(password, password_hash)
    BCrypt::Password.new(password_hash) == password
  end

  def self.find_by_username(username)
    db.execute("SELECT * FROM #{table_name} WHERE username = ?", [username]).first
  end

  def self.find_by_id(id)
    db.execute("SELECT * FROM #{table_name} WHERE id = ?", [id]).first
  end

  # Insert data into the table with email validation
  def self.insert(data)
    validate_email!(data[:email]) if data[:email]
    super(data)
  end

  # Validates the email format
  def self.validate_email!(email)
    uri = URI::MailTo::EMAIL_REGEXP
    raise 'Invalid email format' unless email.match?(uri)
  rescue StandardError
    raise 'Invalid email format'
  end

  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      username TEXT UNIQUE NOT NULL CHECK (LENGTH(username) >= 3 AND LENGTH(username) <= 20),
      email TEXT UNIQUE NOT NULL CHECK (email LIKE '%@%.%'),
      password_hash TEXT NOT NULL,
      profile_picture_id TEXT, -- optional, can store URL or file path
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    SQL
  end
end
