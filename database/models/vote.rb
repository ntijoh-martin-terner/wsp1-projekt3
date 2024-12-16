require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class VoteModel < BaseModel
  def self.table_name
    @table_name ||= 'vote'
  end

  # Cast or update a user's vote
  def self.cast_vote(user_id:, vote_type:, post_id: nil, comment_id: nil)
    # Check if an existing vote already exists
    existing_vote = db.execute(<<-SQL, [user_id, post_id, comment_id]).first
      SELECT * FROM #{table_name}
      WHERE user_id = ? AND post_id IS ? AND comment_id IS ?
    SQL

    if existing_vote
      if existing_vote['vote_type'] == vote_type
        # If the user clicks the same vote again, remove it (toggle off)
        db.execute(<<-SQL, [user_id, post_id, comment_id])
          DELETE FROM #{table_name}
          WHERE user_id = ? AND post_id IS ? AND comment_id IS ?
        SQL
      else
        # Update the vote type if the user switches between upvote/downvote
        db.execute(<<-SQL, [vote_type, user_id, post_id, comment_id])
          UPDATE #{table_name}
          SET vote_type = ?
          WHERE user_id = ? AND post_id IS ? AND comment_id IS ?
        SQL
      end
    else
      # Insert a new vote
      db.execute(<<-SQL, [user_id, post_id, comment_id, vote_type])
        INSERT INTO #{table_name} (user_id, post_id, comment_id, vote_type)
        VALUES (?, ?, ?, ?)
      SQL
    end
  end

  # Get the total votes for a post or comment
  def self.total_votes(post_id: nil, comment_id: nil)
    db.execute(<<-SQL, [post_id, comment_id]).first['total_votes'] || 0
      SELECT SUM(vote_type) AS total_votes
      FROM #{table_name}
      WHERE post_id IS ? AND comment_id IS ?
    SQL
  end

  # Get the user's current vote for a post or comment
  def self.user_vote(user_id:, post_id: nil, comment_id: nil)
    row = db.execute(<<-SQL, [user_id, post_id, comment_id]).first
      SELECT vote_type
      FROM #{table_name}
      WHERE user_id = ? AND post_id IS ? AND comment_id IS ?
    SQL
    row ? row['vote_type'] : 0
  end

  def self.create
    # Static method to fetch pseudo-random posts
    super(<<-SQL)
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      comment_id INTEGER, -- Nullable: Used for comments
      post_id INTEGER,    -- Nullable: Used for posts
      vote_type INTEGER NOT NULL CHECK (vote_type IN (1, -1)), -- 1 for upvote, -1 for downvote
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(user_id, post_id, comment_id) -- Ensures a user can only vote once per post/comment
    SQL
  end
end
