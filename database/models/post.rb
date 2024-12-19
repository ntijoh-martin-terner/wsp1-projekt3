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
      channel.name AS channel_name,
      COALESCE(GROUP_CONCAT(media.media_url), NULL) AS media_urls
    FROM post
    JOIN user ON post.user_id = user.id
    JOIN channel ON post.channel_id = channel.id
    LEFT JOIN media ON media.post_id = post.id
    GROUP BY post.id, user.username, channel.name
    ORDER BY substr(post.id * ?, length(post.id) + 2) -- Seeded pseudo-random order
    LIMIT ? OFFSET ?
    SQL
  end

  def self.get_post_from_id(post_id)
    db.execute(<<-SQL, [post_id]).first
    SELECT
      post.*,
      user.username AS username,
      channel.name AS channel_name,
      COALESCE(GROUP_CONCAT(media.media_url), NULL) AS media_urls
    FROM post
    JOIN user ON post.user_id = user.id
    JOIN channel ON post.channel_id = channel.id
    LEFT JOIN media ON media.post_id = post.id
    WHERE post.id = ?
    GROUP BY post.id, user.username, channel.name
    LIMIT 1
    SQL
  end

  def self.create
    # Static method to fetch pseudo-random posts
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      user_id INTEGER REFERENCES user(id) ON DELETE CASCADE, -- Links to the user table, deletes posts if user is deleted
      channel_id INTEGER REFERENCES channel(id) ON DELETE CASCADE, -- Links to subreddit-like groups
      title TEXT NOT NULL CHECK (LENGTH(title) <= 100), -- Max title length: 100 characters
      content TEXT NOT NULL CHECK (LENGTH(content) <= 1000), -- Max content length: 1000 characters
      -- media_url TEXT, -- Optional media (image, video, etc.)
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Post creation time
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Post last update time
    SQL
  end
end
