require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class PostModel < BaseModel
  def self.random_posts(seed, offset, limit)
    db.execute(<<-SQL, [seed, limit, offset])
      SELECT *#{' '}
      FROM post
      ORDER BY ABS((id * 12345) + ?) -- Seeded pseudo-random order
      LIMIT ? OFFSET ?
    SQL
  end

  def self.get_post_from_id(post_id)
    db.execute(<<-SQL, [post_id]).first
      SELECT *
      FROM post
      WHERE id = ?
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
      upvotes INTEGER DEFAULT 0, -- Upvote count
      downvotes INTEGER DEFAULT 0, -- Downvote count
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Post creation time
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Post last update time
    SQL
  end
end
