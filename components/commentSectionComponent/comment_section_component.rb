# frozen_string_literal: true

require BASE_COMPONENT_PATH
require File.join(DATABASE_PATH, '/models/comment.rb')

class CommentSectionComponent < BaseComponent
  def initialize(post, comments, parent_id, depth = 1, offset = 0, limit = 10)
    @comments = comments
    @parent_id = parent_id
    @post = post
    @offset = offset
    @limit = limit
    @depth = depth
    @current_comments = @comments[@parent_id] || []
    # p @current_comments
    super()
  end

  def render
    return '' if @current_comments.empty? || @depth > 100

    super()
  end
end
