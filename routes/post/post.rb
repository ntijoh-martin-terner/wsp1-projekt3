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
    @offset = params[:offset]&.to_i || 0
    @limit = [params[:limit]&.to_i || 40, 40].min

    @user_id = session[:user_id]

    @comments = Comment.get_comments(post_id: post_id, user_id: @user_id, limit: @limit, offset: @offset)

    @grouped_comments = @comments.group_by { |comment| comment['parent_comment_id'] }

    erb :"posts/post"
  end

  post '/:post_id/comment' do |post_id|
    parent_id = params[:parent_id].empty? ? nil : params[:parent_id]
    content = params[:content]

    # Validate the comment
    redirect back if content.strip.empty?

    # Save the comment to the database
    Comment.insert(post_id: post_id, parent_comment_id: parent_id, user_id: session[:user_id], comment_text: content)
    # Hardcoded user_id for now

    # Redirect back to the same post page
    redirect back
  end

  get '/:post_id/comments/:comment_id/vote' do |post_id, comment_id|
  end

  get '/:post_id/comments/?:comment_id?' do |post_id, comment_id|
    @post = PostModel.get_post_from_id(post_id)

    @user_id = session[:user_id]
    @offset = params[:offset]&.to_i || 0
    @limit = [params[:limit]&.to_i || 40, 40].min

    # Decide whether to fetch root comments or threaded comments
    @comments = if comment_id
                  Comment.get_comments(root_id: comment_id, post_id: post_id, limit: @limit, offset: @offset,
                                       user_id: @user_id)
                else
                  Comment.get_comments(post_id: post_id, limit: @limit, offset: @offset, user_id: @user_id)
                end

    if @comments.empty?
      halt 204 # No Content
    end

    @grouped_comments = @comments.group_by { |comment| comment['parent_comment_id'] }

    CommentSectionComponent(@post, @grouped_comments, comment_id&.to_i, 1, @offset, @limit)
  end
end
