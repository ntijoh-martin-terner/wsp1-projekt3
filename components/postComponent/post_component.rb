# frozen_string_literal: true

require BASE_COMPONENT_PATH
require File.join(DATABASE_PATH, '/models/comment.rb')

class PostComponent < BaseComponent
  def truncate(text, length: 100, omission: '...')
    return text if text.length <= length

    "#{text[0, length]}#{omission}"
  end

  def initialize(post, preview = true)
    @post = post
    @comment_count = Comment.comment_count(post['id'])
    @preview = preview
    super()
  end
end
