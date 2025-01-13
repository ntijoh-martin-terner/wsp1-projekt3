# frozen_string_literal: true

require_relative '../config/environment'
require 'fileutils'
require_relative './models/user'
require_relative './models/vote'
require_relative './models/post'
require_relative './models/channel/channel'
require_relative './models/channel/permission'
require_relative './models/channel/channel_role'
require_relative './models/channel/role_permission'
require_relative './models/channel/channel_membership'
require_relative './models/comment'
require_relative './models/media'

# Drop tables in reverse dependency order
ChannelMembershipModel.drop
RolePermissionModel.drop
ChannelRoleModel.drop
PermissionModel.drop
CommentModel.drop
PostModel.drop
VoteModel.drop
ChannelModel.drop
ChannelModel.create
UserModel.drop
MediaModel.drop
MediaModel.create

# Create tables
UserModel.create
PostModel.create
CommentModel.create
PermissionModel.create
VoteModel.create
ChannelRoleModel.create
RolePermissionModel.create
ChannelMembershipModel.create

# Seed permissions (global)
PermissionModel.insert(name: 'delete_post')
PermissionModel.insert(name: 'ban_user')
PermissionModel.insert(name: 'edit_group_details')
PermissionModel.insert(name: 'approve_post')

# Seed groups
channel_id = ChannelModel.insert(name: 'Ruby Enthusiasts', description: 'A group for Ruby developers')

# Seed group-specific roles
owner_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Owner')
moderator_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Moderator')
member_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Member')

# Assign permissions to roles
RolePermissionModel.insert(channel_role_id: owner_role_id,
                           permission_id: PermissionModel.find_id_by_name(name: 'delete_post'))
RolePermissionModel.insert(channel_role_id: owner_role_id,
                           permission_id: PermissionModel.find_id_by_name(name: 'ban_user'))
RolePermissionModel.insert(channel_role_id: moderator_role_id,
                           permission_id: PermissionModel.find_id_by_name(name: 'approve_post'))

# Seed users
user1_id = UserModel.insert(username: 'john', password_hash: UserModel.hash_password('secretPassword'),
                            email: 'john@gmail.com')
user2_id = UserModel.insert(username: 'jane', password_hash: UserModel.hash_password('anotherPassword'),
                            email: 'jane@gmail.com')
user3_id = UserModel.insert(username: 'doe', password_hash: UserModel.hash_password('testPassword'),
                            email: 'doe@gmail.com')

# Assign users to groups with roles
ChannelMembershipModel.insert(user_id: user1_id, channel_id: channel_id, channel_role_id: owner_role_id) # John is Owner
ChannelMembershipModel.insert(user_id: user2_id, channel_id: channel_id, channel_role_id: moderator_role_id) # Jane is Moderator
ChannelMembershipModel.insert(user_id: user3_id, channel_id: channel_id, channel_role_id: member_role_id) # Doe is Member

# Seed posts
upload_dir = File.expand_path('../public/uploads', __dir__) # Define upload directory

# Seed first post
post1_id = PostModel.insert(
  user_id: user1_id,
  channel_id: channel_id,
  title: 'First Post!',
  content: 'Hello, world! This is my first post.'
)

# Add media attachments for post1
hero_image_path = File.expand_path('../public/img/hero/hero.png', __dir__)
office_image_path = File.expand_path('../public/img/about/office.jpg', __dir__)
file = { filename: 'hero.png', tempfile: File.open(hero_image_path) }
MediaModel.add_media(post_id: post1_id, file: file, upload_dir: upload_dir)
MediaModel.add_media(post_id: post1_id, file: { filename: 'hero2.png', tempfile: File.open(hero_image_path) },
                     upload_dir: upload_dir)
MediaModel.add_media(post_id: post1_id, file: { filename: 'office.jpg', tempfile: File.open(office_image_path) },
                     upload_dir: upload_dir)

post2_id = PostModel.insert(
  user_id: user1_id,
  channel_id: channel_id,
  title: 'Another Post :)',
  content: 'This is another post with just text content.'
)
post3_id = PostModel.insert(
  user_id: user2_id,
  channel_id: channel_id,
  title: 'mod',
  content: 'Moderator Jane’s post in the Ruby group!'
)

(0..30).each do |i|
  PostModel.insert(
    user_id: user2_id,
    channel_id: channel_id,
    title: 'SPAM',
    content: "Spam number ##{i}"
  )
end

# Insert a comment for the first post
comment1_id = CommentModel.insert(
  user_id: user1_id,
  post_id: post3_id,
  comment_text: 'This is my first comment on the post!',
  parent_comment_id: nil # Top-level comment (no parent)
)

# Insert a second comment on the same post by another user
comment2_id = CommentModel.insert(
  user_id: user2_id,
  post_id: post3_id,
  comment_text: 'This is a comment on the first post as well!',
  parent_comment_id: nil # Top-level comment (no parent)
)

# Insert a reply to the first comment (nested comment)
reply1_id = CommentModel.insert(
  user_id: user2_id,
  post_id: post3_id,
  comment_text: 'Replying to the first comment!',
  parent_comment_id: comment1_id
)

# Insert a reply to the second comment (nested comment)
reply2_id = CommentModel.insert(
  user_id: user1_id,
  post_id: post3_id,
  comment_text: 'Replying to the second comment!',
  parent_comment_id: comment2_id
)

# Seed votes for posts
VoteModel.cast_vote(user_id: user1_id, post_id: post1_id, vote_type: 1) # John upvotes post 1
VoteModel.cast_vote(user_id: user2_id, post_id: post1_id, vote_type: 1) # Jane upvotes post 1
VoteModel.cast_vote(user_id: user3_id, post_id: post1_id, vote_type: 1) # Doe upvotes post 1

VoteModel.cast_vote(user_id: user2_id, post_id: post2_id, vote_type: 1) # Jane upvotes post 2
VoteModel.cast_vote(user_id: user3_id, post_id: post2_id, vote_type: -1) # Doe downvotes post 2

VoteModel.cast_vote(user_id: user1_id, post_id: post3_id, vote_type: 1) # John upvotes post 3

# Seed votes for comments
VoteModel.cast_vote(user_id: user2_id, comment_id: comment1_id, vote_type: 1) # Jane upvotes comment 1
VoteModel.cast_vote(user_id: user3_id, comment_id: comment1_id, vote_type: -1) # Doe downvotes comment 1

VoteModel.cast_vote(user_id: user1_id, comment_id: comment2_id, vote_type: 1) # John upvotes comment 2
VoteModel.cast_vote(user_id: user3_id, comment_id: comment2_id, vote_type: 1) # Doe upvotes comment 2

VoteModel.cast_vote(user_id: user2_id, comment_id: reply1_id, vote_type: 1) # Jane upvotes reply 1
VoteModel.cast_vote(user_id: user1_id, comment_id: reply2_id, vote_type: -1) # John downvotes reply 2

p CommentModel.get_comments(post_id: post3_id, user_id: user1_id)

# Display seeded comments with dynamic votes
puts "Comments for post #{post3_id}:"
comments = CommentModel.get_comments(post_id: post3_id, user_id: user1_id)

comments.each do |comment|
  total_votes = VoteModel.total_votes(comment_id: comment['id'])
  puts "Comment ID: #{comment['id']}, Text: #{comment['comment_text']}, Votes: #{total_votes}"
end
