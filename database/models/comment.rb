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

  def self.get_comments(root_id: nil, post_id: nil, user_id: nil, limit: 10, depth_limit: 6, offset: 0)
    arguments = [depth_limit, user_id, depth_limit, post_id, offset, limit]
    arguments = [root_id, *arguments] unless root_id.nil?

    db.execute(<<-SQL, arguments)
      WITH RECURSIVE comment_tree AS (
        SELECT id,
               post_id,
               user_id,
               comment_text,
               created_at,
               parent_comment_id,
               created_at AS root_created_at,
               0 AS level,
               ROW_NUMBER() OVER (
                 ORDER BY created_at ASC, id ASC
               ) AS global_root_index -- Sequential number for root comments
        FROM comment
        --WHERE parent_comment_id IS NULL -- Start with top-level comments
        WHERE #{root_id.nil? ? 'parent_comment_id IS NULL' : 'parent_comment_id = ?'} -- Start from top-level OR specified root comment

        UNION ALL

        SELECT c.id, c.post_id, c.user_id, c.comment_text, c.created_at, c.parent_comment_id, ct.root_created_at, ct.level + 1 AS level, ct.global_root_index -- Assign global_root_index to root comments
        FROM comment c
        JOIN comment_tree ct ON c.parent_comment_id = ct.id
        WHERE ct.level < ? -- Prevent exceeding the depth limit
      )
      SELECT
        ct.*,
        u.username,
        u.profile_picture_id,
        IFNULL(SUM(v.vote_type), 0) AS total_votes, -- Total votes for the comment
        MAX(CASE WHEN v.user_id = ? THEN v.vote_type ELSE NULL END) AS user_vote, -- User's vote if exists

        -- Check for the existence of more sibling comments after the current one
        CASE
            WHEN ct.parent_comment_id IS NULL THEN
                EXISTS (
                    SELECT 1
                    FROM comment c2
                    WHERE c2.parent_comment_id IS NULL
                      AND (c2.created_at > ct.created_at OR (c2.created_at = ct.created_at AND c2.id > ct.id))
                )
            ELSE
                EXISTS (
                    SELECT 1
                    FROM comment c2
                    WHERE c2.parent_comment_id = ct.parent_comment_id
                      AND (c2.created_at > ct.created_at OR (c2.created_at = ct.created_at AND c2.id > ct.id))
                )
        END AS has_more_siblings,

        -- Updated: Only check for children if level < depth_limit
        CASE
          WHEN ct.level = ? AND EXISTS (
            SELECT 1
            FROM comment c2
            WHERE c2.parent_comment_id = ct.id
          ) THEN 1
          ELSE 0
        END AS has_unloaded_comments

      FROM comment_tree ct
      LEFT JOIN vote v ON ct.id = v.comment_id
      LEFT JOIN user u ON ct.user_id = u.id
      WHERE ct.post_id = ?
        AND ct.global_root_index > ?
      GROUP BY
        ct.id, ct.post_id, ct.user_id, ct.comment_text, ct.created_at, ct.parent_comment_id,
        u.username, u.profile_picture_id
      ORDER BY ct.root_created_at ASC, ct.created_at ASC, ct.level ASC
      LIMIT ?;
    SQL
  end

  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      post_id INTEGER NOT NULL REFERENCES post(id) ON DELETE CASCADE,
      user_id INTEGER NOT NULL REFERENCES user(id) ON DELETE CASCADE,
      comment_text TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      parent_comment_id INTEGER DEFAULT NULL, -- Self-referencing foreign key
      FOREIGN KEY (parent_comment_id) REFERENCES comment (id)
        ON DELETE CASCADE
    SQL
  end
end
