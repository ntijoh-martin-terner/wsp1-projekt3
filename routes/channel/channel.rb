require APP_PATH

require File.join(DATABASE_PATH, '/models/channel/channel.rb')
require File.join(DATABASE_PATH, '/models/user.rb')
require File.join(DATABASE_PATH, '/models/channel/role_permission.rb')
require File.join(DATABASE_PATH, '/models/channel/permission.rb')
require File.join(DATABASE_PATH, '/models/channel/channel_role.rb')
require File.join(DATABASE_PATH, '/models/channel/channel_membership.rb')

class Channel < App
  get '/:channel_id' do |channel_id|
    redirect "/channel/#{channel_id}/random"
    # channel = ChannelModel.get_channel_from_id(channel_id)
    # # Handle sorting

    # @order_by = case params[:sort]
    #             when 'recent' then 'post.created_at DESC'
    #             when 'old' then 'post.created_at ASC'
    #             when 'upvotes' then 'upvotes DESC'
    #             when 'votes' then 'votes DESC'
    #             when 'downvotes' then 'downvotes DESC'
    #             else 'post.created_at DESC'
    #             end

    # # Handle search
    # @search_query = params[:search] || nil

    # @channel_id = channel_id
    # @name = channel['name']
    # @description = channel['description']
    # @created_at = channel['created_at']
    # @limit = 20
    # @offset = 0
    # @channel_ids = [channel_id.to_i]
    # @posts = PostModel.retrieve_posts(offset: @offset, limit: @limit, channel_ids: [channel_id.to_i],
    #                                   search_query: @search_query, order_by: @order_by)
    # erb :'posts/channel'
  end

  get %r{/([^/]+)/(new|hot|controversial|random)} do |channel_id, sorting|
    channel = ChannelModel.get_channel_from_id(channel_id)

    halt 404 unless channel

    @limit = 10
    @offset = 0

    @order_by = case sorting
                when 'new' then 'post.created_at DESC'
                when 'hot' then 'post.created_at ASC'
                when 'controversial' then 'downvotes DESC'
                end

    # @order_by = case params[:sort]
    #             when 'recent' then 'post.created_at DESC'
    #             when 'old' then 'post.created_at ASC'
    #             when 'upvotes' then 'upvotes DESC'
    #             when 'votes' then 'votes DESC'
    #             when 'downvotes' then 'downvotes DESC'
    #             else @order_by
    #             end

    @random_order = true if sorting == 'random'

    # Special handling for random sorting
    @seed = @random_order ? rand(25_000) : nil

    @channel_ids = [channel_id.to_i]

    @search_query = params[:search] || nil

    @channel_id = channel_id
    @name = channel['name']
    @description = channel['description']
    @created_at = channel['created_at']

    @posts = PostModel.retrieve_posts(
      offset: @offset,
      limit: @limit,
      order_by: @order_by,
      channel_ids: @channel_ids,
      search_query: @search_query,
      random_order: @random_order,
      seed: @seed
    )

    erb :"posts/channel"
  end

  post '/new' do
    title = params[:title]
    description = params[:description]

    # Seed groups
    channel_id = ChannelModel.insert(name: title, description: description)

    # Seed group-specific roles
    owner_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Owner')
    moderator_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Moderator')
    member_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Member')

    # Assign permissions to roles
    RolePermissionModel.insert(channel_role_id: owner_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'delete_post'))
    RolePermissionModel.insert(channel_role_id: owner_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'ban_user'))
    RolePermissionModel.insert(channel_role_id: owner_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'admin'))
    RolePermissionModel.insert(channel_role_id: moderator_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'delete_post'))

    user_id = session[:user_id]

    # Assign users to groups with roles
    ChannelMembershipModel.insert(user_id: user_id, channel_id: channel_id, channel_role_id: owner_role_id) # John is Owner

    # Save the channel to the database
    # db.execute('INSERT INTO channels (title, description) VALUES (?, ?)', [title, description])

    redirect "/channel/#{channel_id}"
  end
end
