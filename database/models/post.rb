require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class PostModel < BaseModel
  def self.table_name
    @table_name ||= 'post'
  end

  def self.random_posts(seed, offset = 0, limit = 100)
    db.execute(<<-SQL, [seed, limit, offset])
    SELECT
      post.*,
      user.username AS username,
      channel.name AS channel_name
    FROM post
    JOIN user ON post.user_id = user.id
    JOIN channel ON post.channel_id = channel.id
    ORDER BY substr(post.id * ?, length(post.id) + 2) -- Seeded pseudo-random order ABS((post.id * 12345) + ?)
    LIMIT ? OFFSET ?
    SQL
  end

  def self.get_post_from_id(post_id)
    db.execute(<<-SQL, [post_id]).first
    SELECT
      post.*,
      user.username AS username,
      channel.name AS channel_name
    FROM post
    JOIN user ON post.user_id = user.id
    JOIN channel ON post.channel_id = channel.id
    WHERE post.id = ?
    LIMIT 1
    SQL
  end

  def self.create
    # Static method to fetch pseudo-random posts
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      user_id INTEGER REFERENCES user(id) ON DELETE CASCADE, -- Links to the user table, deletes posts if user is deleted
      channel_id INTEGER REFERENCES channel(id) ON DELETE CASCADE, -- Links to subreddit-like groups
      content TEXT NOT NULL, -- Post content (text)
      media_url TEXT, -- Optional media (image, video, etc.)
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Post creation time
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Post last update time
    SQL
  end
end
