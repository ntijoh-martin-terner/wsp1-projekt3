require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class PostModel < BaseModel
  def self.table_name
    @table_name ||= 'post'
  end

  def self.delete_post(post_id: nil)
    db.execute(<<-SQL, [post_id])
      DELETE FROM post WHERE id = ?
    SQL
  end

  def self.retrieve_posts(seed: nil, offset: 0, limit: 100, channel_ids: nil, user_ids: nil, order_by: nil, random_order: false, search_query: nil)
    sql = <<-SQL
      SELECT
        post.*,
        user.username AS username,
        channel.name AS channel_name,
        COALESCE(GROUP_CONCAT(media.media_url), NULL) AS media_urls,
        COALESCE(SUM(CASE WHEN vote.vote_type = 1 THEN 1 ELSE 0 END), 0) AS upvotes,
        COALESCE(SUM(CASE WHEN vote.vote_type = -1 THEN 1 ELSE 0 END), 0) AS downvotes,
        COALESCE(SUM(vote.vote_type), 0) AS votes
      FROM post
      JOIN user ON post.user_id = user.id
      JOIN channel ON post.channel_id = channel.id
      LEFT JOIN media ON media.post_id = post.id
      LEFT JOIN vote ON vote.post_id = post.id
      WHERE 1 = 1
    SQL

    params = []

    # Add filtering for channel_ids if provided
    if channel_ids && !channel_ids.empty?
      placeholders = Array.new(channel_ids.size, '?').join(', ')
      sql += " AND channel.id IN (#{placeholders})"
      params.concat(channel_ids)
    end

    if user_ids && !user_ids.empty?
      placeholders = Array.new(user_ids.size, '?').join(', ')
      sql += " AND user.id IN (#{placeholders})"
      params.concat(user_ids)
    end

    # Add search filtering if search_query is provided
    if search_query && !search_query.strip.empty?
      sql += ' AND (post.title LIKE ? OR post.content LIKE ?)'
      params << "%#{search_query}%" << "%#{search_query}%"
    end

    # Determine the ORDER BY clause
    if random_order
      sql += " GROUP BY post.id \n ORDER BY substr(post.id * ?, length(post.id) + 2)"
      params << seed
    elsif order_by
      sql += " GROUP BY post.id \n ORDER BY #{order_by}"
    else
      sql += " GROUP BY post.id \n ORDER BY post.created_at DESC"
    end

    # Add limit and offset
    sql += ' LIMIT ? OFFSET ?'
    params.push(limit, offset)

    # # Debugging: Print the query and params
    # puts "SQL Query: #{sql}"
    # p "Params: #{params}"

    db.execute(sql, params)
    # p "Results: #{result}"
  end

  # def self.order_by_clause(order_by)
  #   case order_by.to_s
  #   when 'created_at_asc'
  #     'post.created_at ASC'
  #   when 'created_at_desc'
  #     'post.created_at DESC'
  #   when 'username_asc'
  #     'user.username ASC'
  #   when 'username_desc'
  #     'user.username DESC'
  #   when 'channel_name_asc'
  #     'channel.name ASC'
  #   when 'channel_name_desc'
  #     'channel.name DESC'
  #   else
  #     raise ArgumentError, "Invalid order_by value: #{order_by}"
  #   end
  # end

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
