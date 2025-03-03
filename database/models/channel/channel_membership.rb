require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class ChannelMembershipModel < BaseModel
  def self.permissions_for(user_id: nil, channel_id: nil)
    db.execute(<<-SQL, [user_id, channel_id])
      SELECT permission.name
      FROM channel_membership
      JOIN role_permission ON role_permission.channel_role_id = channel_membership.channel_role_id
      JOIN permission ON permission.id = role_permission.permission_id
      WHERE channel_membership.user_id = ? AND channel_membership.channel_id = ?
    SQL

    #  JOIN channel_permission ON channel_role.id = channel_permission.channel_role_id
    #   JOIN permission ON channel_permission.permission_id = permission.id
  end

  def self.remove_role_from_user(user_id:, channel_id:, channel_role_id:)
    db.execute(<<-SQL, [user_id, channel_id, channel_role_id])
      DELETE FROM channel_membership
      WHERE user_id = ? AND channel_id = ? AND channel_role_id = ?
    SQL
  end

  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      user_id INTEGER REFERENCES user(id),
      channel_id INTEGER REFERENCES channel(id),
      channel_role_id INTEGER REFERENCES channel_role(id)
    SQL
  end
end
