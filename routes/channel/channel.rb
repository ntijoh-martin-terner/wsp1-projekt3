require APP_PATH

require File.join(DATABASE_PATH, '/models/channel/channel.rb')
require File.join(DATABASE_PATH, '/models/user.rb')
require File.join(DATABASE_PATH, '/models/channel/role_permission.rb')
require File.join(DATABASE_PATH, '/models/channel/permission.rb')
require File.join(DATABASE_PATH, '/models/channel/channel_role.rb')
require File.join(DATABASE_PATH, '/models/channel/channel_membership.rb')

class Channel < App
  helpers do
    def current_user
      @current_user ||= UserModel.find_by_id(id: session['user_id'])
    end

    def user_has_permission?(required_permissions, channel_id)
      return false unless current_user

      permissions = ChannelMembershipModel.permissions_for(user_id: session['user_id'], channel_id: channel_id)

      @roles = ChannelRoleModel.get_all_editable_roles(channel_id: channel_id)

      @users_with_roles = ChannelRoleModel.users_with_editable_roles(channel_id: channel_id)

      @permissions = PermissionModel.get_all_removeable_permissions

      permission_names = permissions.map { |row| row['name'] } # Extract permission names

      # Define the required permissions for access
      # required_permissions = %w[adminpage owner]

      (permission_names & required_permissions).any?
    end
  end

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

  get '/:channel_id/adminpage' do |channel_id|
    user_id = session[:user_id]
    halt 403, 'Not authorized' unless user_id # Ensure user is logged in

    @channel = ChannelModel.get_channel_from_id(channel_id)
    @channel_id = channel_id

    halt 404, 'Does not exist' unless @channel # Ensure user is logged in

    # Fetch permissions for the user in this channel
    permissions = ChannelMembershipModel.permissions_for(user_id: user_id, channel_id: channel_id)

    p permissions # currently only channelRoleModel name but needs to be PermissionModel name
    p 'permissions ^'

    @roles = ChannelRoleModel.get_all_editable_roles(channel_id: channel_id)

    @users_with_roles = ChannelRoleModel.users_with_editable_roles(channel_id: channel_id)

    p @users_with_roles

    p @roles
    p '^^^roles ^^ ^'

    @permissions = PermissionModel.get_all_removeable_permissions

    permission_names = permissions.map { |row| row['name'] } # Extract permission names

    # Define the required permissions for access
    required_permissions = %w[adminpage owner]

    # Check if user has any of the required permissions
    halt 403, 'Not authorized' unless (permission_names & required_permissions).any?

    # Render admin page
    erb :"channel/adminpage"
  end

  post '/new' do
    title = params[:title]
    description = params[:description]

    # Seed groups
    channel_id = ChannelModel.insert(name: title, description: description)

    # Seed group-specific roles
    owner_role_id = ChannelRoleModel.insert(channel_id: channel_id, editable: 0, name: 'Owner')
    moderator_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Moderator')
    admin_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Admin')
    member_role_id = ChannelRoleModel.insert(channel_id: channel_id, name: 'Member')

    # Assign permissions to roles
    RolePermissionModel.insert(channel_role_id: owner_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'delete_post'))
    RolePermissionModel.insert(channel_role_id: owner_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'ban_user'))
    RolePermissionModel.insert(channel_role_id: owner_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'owner'))
    RolePermissionModel.insert(channel_role_id: admin_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'adminpage'))
    RolePermissionModel.insert(channel_role_id: admin_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'delete_post'))
    RolePermissionModel.insert(channel_role_id: moderator_role_id,
                               permission_id: PermissionModel.find_id_by_name(name: 'delete_post'))

    user_id = session[:user_id]

    # Assign users to groups with roles
    ChannelMembershipModel.insert(user_id: user_id, channel_id: channel_id, channel_role_id: owner_role_id)
    ChannelMembershipModel.insert(user_id: user_id, channel_id: channel_id, channel_role_id: member_role_id)

    # Save the channel to the database
    # db.execute('INSERT INTO channels (title, description) VALUES (?, ?)', [title, description])

    redirect "/channel/#{channel_id}"
  end

  post '/:channel_id/update_role_permissions' do |channel_id|
    halt 403 unless user_has_permission?(%w[owner adminpage], channel_id)

    role_name = params[:role_name]
    permission_name = params[:permission]
    add_permission = params[:add] == 'true'

    # Find the role ID from the role name
    role_id = ChannelRoleModel.find_id_by_name_and_group(channel_id: channel_id, name: role_name)
    halt 404, 'Role not found' unless role_id

    # Find the permission ID
    permission_id = PermissionModel.find_id_by_name(name: permission_name) # db.execute('SELECT id FROM permission WHERE name = ? LIMIT 1', permission_name).first&.dig('id')
    halt 404, 'Permission not found' unless permission_id

    if add_permission
      ChannelRoleModel.add_permission(role_id: role_id, permission_id: permission_id)
    else
      ChannelRoleModel.remove_permission(role_id: role_id, permission_id: permission_id)
    end

    redirect back
  end

  # add a user's role
  post '/:channel_id/add_user_role' do |channel_id|
    halt 403 unless user_has_permission?(%w[owner adminpage], channel_id)

    username = params[:username]
    role_id = params[:role_id]

    user = UserModel.find_by_username(username: username)
    halt 404, 'User not found' unless user

    ChannelMembershipModel.insert(user_id: user['id'], channel_id: channel_id, channel_role_id: role_id)
    redirect back
  end

  # remove a user's role
  post '/:channel_id/remove_user_role' do |channel_id|
    halt 403 unless user_has_permission?(%w[owner adminpage], channel_id)

    user_id = params[:user_id]
    role_id = params[:role_id]

    # user = UserModel.find_by_username(username: username)
    # halt 404, 'User not found' unless user

    ChannelMembershipModel.remove_role_from_user(user_id: user_id, channel_id: channel_id, channel_role_id: role_id)
    redirect back
  end

  # Change a user's role
  post '/:channel_id/create_role' do |channel_id|
    halt 403 unless user_has_permission?(%w[owner adminpage], channel_id)

    role_name = params[:role_name]

    ChannelRoleModel.insert(channel_id: channel_id, name: role_name, editable: 1)

    # user = UserModel.find_by_username(username: username)
    # halt 404, 'User not found' unless user

    # ChannelMembershipModel.update_role(user_id: user.id, channel_id: channel_id, new_role_id: new_role_id)
    redirect back
  end
end
