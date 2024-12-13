# frozen_string_literal: true

require APP_PATH
require File.join(DATABASE_PATH, '/models/post.rb')
require File.join(DATABASE_PATH, '/models/comment.rb')
require 'digest'

class Post < App
  before do
    redirect '/404' if session[:user_id].nil?
  end

  get '/:post_id' do |post_id|
    @post = PostModel.get_post_from_id(post_id)
    # @comment_count = Comment.comment_count(post_id)
    @comments = Comment.get_comments(post_id)

    @grouped_comments = @comments.group_by { |comment| comment['parent_comment_id'] }

    p @comments

    p 'PFEJ GROUPED COMMENTS'

    p @grouped_comments

    erb :"posts/post"
  end

  post '/:post_id/comment' do |post_id|
    parent_id = params[:parent_id] == 'nil' ? nil : params[:parent_id]
    content = params[:content]

    # Validate the comment
    redirect back if content.strip.empty?

    # Save the comment to the database
    Comment.create_comment(post_id: post_id, parent_id: parent_id, user_id: session[:user_id], content: content)
    # Hardcoded user_id for now

    # Redirect back to the same post page
    redirect "/post/#{post_id}"
  end
end
