require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class Comment < BaseModel
  def self.comment_count(post_id)
    db.execute(<<-SQL, post_id)[0]['comment_count']
      SELECT COUNT(*) AS comment_count
      FROM comment
      WHERE post_id = ?;
    SQL
  end

  def self.get_comments(post_id)
    db.execute(<<-SQL, post_id)
      WITH RECURSIVE comment_tree AS (
        SELECT comment_id, post_id, user_id, comment_text, created_at, parent_comment_id
        FROM comment
        WHERE parent_comment_id IS NULL -- Start with top-level comments

        UNION ALL

        SELECT c.comment_id, c.post_id, c.user_id, c.comment_text, c.created_at, c.parent_comment_id
        FROM comment c
        JOIN comment_tree ct ON c.parent_comment_id = ct.comment_id
      )
      SELECT * FROM comment_tree WHERE post_id = ?;

    SQL
  end

  def self.create
    super(<<-SQL)
      comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
      post_id INTEGER NOT NULL REFERENCES post(id) ON DELETE CASCADE,
      user_id INTEGER NOT NULL REFERENCES user(id) ON DELETE CASCADE,
      comment_text TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      parent_comment_id INTEGER, -- Self-referencing foreign key
      FOREIGN KEY (parent_comment_id) REFERENCES comment (comment_id)
        ON DELETE CASCADE
    SQL
  end
end
