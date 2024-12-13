# frozen_string_literal: true

require BASE_COMPONENT_PATH
require File.join(DATABASE_PATH, '/models/comment.rb')

class CommentFormComponent < BaseComponent
  def initialize(post, parent_id, start_visible = false)
    @post = post
    @parent_id = parent_id
    @start_visible = start_visible
    super()
  end
end
