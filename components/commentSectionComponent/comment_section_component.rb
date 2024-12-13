# frozen_string_literal: true

require BASE_COMPONENT_PATH
require File.join(DATABASE_PATH, '/models/comment.rb')

class CommentSectionComponent < BaseComponent
  def initialize(post, comments, parent_id, depth = 1)
    @comments = comments
    @parent_id = parent_id
    @post = post
    @depth = depth
    @current_comments = @comments[@parent_id] || []
    # p @current_comments
    super()
  end

  def render
    return '' if @current_comments.empty? || @depth > 4

    super()
  end
end
