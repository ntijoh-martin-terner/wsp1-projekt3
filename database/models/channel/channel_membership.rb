require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class ChannelMembershipModel < BaseModel
  def self.permissions_for(user_id:, channel_id:)
    db.execute(<<-SQL, user_id, channel_id)
      SELECT permission.name
      FROM channel_membership
      JOIN channel_role ON channel_membership.channel_role_id = channel_role.id
      JOIN channel_permission ON channel_role.id = channel_permission.channel_role_id
      JOIN permission ON channel_permission.permission_id = permission.id
      WHERE channel_membership.user_id = ? AND channel_membership.channel_id = ?
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
