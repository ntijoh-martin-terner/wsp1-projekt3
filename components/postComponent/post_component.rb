# frozen_string_literal: true

require BASE_COMPONENT_PATH
require File.join(DATABASE_PATH, '/models/comment.rb')
require File.join(DATABASE_PATH, '/models/vote.rb')

class PostComponent < BaseComponent
  def truncate(text, length: 100, omission: '...')
    return text if text.length <= length

    "#{text[0, length]}#{omission}"
  end

  def time_ago_in_words(timestamp)
    seconds_diff = (Time.now - timestamp).to_i
    case seconds_diff
    when 0..59
      "#{seconds_diff} seconds ago"
    when 60..3599
      "#{seconds_diff / 60} minutes ago"
    when 3600..86_399
      "#{seconds_diff / 3600} hours ago"
    else
      "#{seconds_diff / 86_400} days ago"
    end
  end

  def initialize(post: nil, preview: true, user_id: nil, base_url: nil)
    # to do: get a @upvotes variable(also rename to upvote_count)
    @post = post
    @base_url = base_url
    @comment_count = CommentModel.comment_count(post_id: post['id'])
    @upvote_count = VoteModel.upvote_count(post_id: post['id'])
    @downvote_count = VoteModel.downvote_count(post_id: post['id'])
    @vote_count = VoteModel.total_votes(post_id: post['id'])
    @user_vote = VoteModel.user_vote(post_id: post['id'], user_id: user_id)
    @preview = preview
    super()
  end
end
