# frozen_string_literal: true

require APP_PATH
require File.join(DATABASE_PATH, '/models/post.rb')
require File.join(DATABASE_PATH, '/models/comment.rb')
require File.join(DATABASE_PATH, '/models/vote.rb')
require File.join(DATABASE_PATH, '/models/media.rb')
require 'digest'

class Post < App
  before do
    redirect '/404' if session[:user_id].nil?
  end

  get '/:post_id' do |post_id|
    @post = PostModel.get_post_from_id(post_id)
    @offset = params[:offset]&.to_i || 0
    @limit = [params[:limit]&.to_i || 20, 20].min

    @user_id = session[:user_id]

    @comments = CommentModel.get_comments(post_id: post_id, user_id: @user_id, limit: @limit, offset: @offset)

    @grouped_comments = @comments.group_by { |comment| comment['parent_comment_id'] }

    erb :"posts/post"
  end

  post '/new' do
    user_id = session[:user_id]
    halt 403, 'Unauthorized' unless user_id

    title = params[:title].strip
    content = params[:content].strip
    channel_name = params[:channel].strip
    images = params[:images]

    halt 400, 'Invalid input' if title.empty? || content.empty? || channel_name.empty?
    halt 400, 'Title too long' if title.length > 30
    halt 400, 'Content too long' if content.length > 2000

    channel = ChannelModel.get_channel_from_name(channel_name: channel_name)
    halt 400, 'Channel does not exist' unless channel

    post_id = PostModel.insert(
      user_id: user_id,
      channel_id: channel['id'],
      title: title,
      content: content
    )

    if images
      images = [images] unless images.is_a?(Array) # Ensure it's an array
      images.first(10).each do |image|
        MediaModel.add_media(post_id: post_id, file: image, upload_dir: 'public/uploads')
      end
    end

    redirect "/post/#{post_id}"
  end

  post '/:post_id/comment' do |post_id|
    parent_id = params[:parent_id].empty? ? nil : params[:parent_id]
    content = params[:content]

    # Validate the comment
    redirect back if content.strip.empty?

    # Save the comment to the database
    CommentModel.insert(post_id: post_id, parent_comment_id: parent_id, user_id: session[:user_id],
                        comment_text: content)
    # Hardcoded user_id for now

    # Redirect back to the same post page
    redirect back
  end

  post '/:post_id/upvote' do |post_id|
    user_id = session[:user_id]
    @user_vote = VoteModel.cast_vote(post_id: post_id, vote_type: 1, user_id: user_id)
    content_type :json
    redirect back
  end
  post '/:post_id/downvote' do |post_id|
    user_id = session[:user_id]
    @user_vote = VoteModel.cast_vote(post_id: post_id, vote_type: -1, user_id: user_id)
    redirect back
  end

  post '/comments/:comment_id/downvote' do |comment_id|
    user_id = session[:user_id]
    @user_vote = VoteModel.cast_vote(comment_id: comment_id, vote_type: -1, user_id: user_id)
    redirect back
  end
  post '/comments/:comment_id/upvote' do |comment_id|
    user_id = session[:user_id]
    @user_vote = VoteModel.cast_vote(comment_id: comment_id, vote_type: 1, user_id: user_id)
    redirect back
  end

  get '/:post_id/comments/?:comment_id?' do |post_id, comment_id|
    @post = PostModel.get_post_from_id(post_id)

    @user_id = session[:user_id]
    @offset = params[:offset]&.to_i || 0
    @limit = [params[:limit]&.to_i || 20, 20].min

    # Decide whether to fetch root comments or threaded comments
    @comments = if comment_id
                  CommentModel.get_comments(root_id: comment_id, post_id: post_id, limit: @limit, offset: @offset,
                                            user_id: @user_id)
                else
                  CommentModel.get_comments(post_id: post_id, limit: @limit, offset: @offset, user_id: @user_id)
                end

    if @comments.empty?
      halt 204 # No Content
    end

    @grouped_comments = @comments.group_by { |comment| comment['parent_comment_id'] }

    CommentSectionComponent(@post, @grouped_comments, comment_id&.to_i, 1, @offset, @limit)
  end
end
