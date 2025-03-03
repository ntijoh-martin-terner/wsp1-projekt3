require BASE_MODEL_PATH
require 'bcrypt'
require 'uri'

class ChannelRoleModel < BaseModel
  def self.add_permission(role_id:, permission_id:)
    db.execute('INSERT INTO role_permission (channel_role_id, permission_id) VALUES (?, ?) ON CONFLICT DO NOTHING',
               [role_id, permission_id])
  end

  def self.remove_permission(role_id: nil, permission_id: nil)
    db.execute('DELETE FROM role_permission WHERE channel_role_id = ? AND permission_id = ?', [role_id, permission_id])
  end

  def self.find_id_by_name_and_group(channel_id: nil, name: nil)
    result = db.execute('SELECT id FROM channel_role WHERE channel_id = ? AND name = ? LIMIT 1', [channel_id, name])
    result.first['id'] if result.any?
  end

  def self.users_with_editable_roles(channel_id: nil)
    db.execute(<<-SQL, channel_id)
      SELECT user.id AS user_id, user.username, channel_role.id AS role_id, channel_role.name AS role_name, channel_role.id AS "role_id"
      FROM channel_membership
      JOIN user ON channel_membership.user_id = user.id
      JOIN channel_role ON channel_membership.channel_role_id = channel_role.id
      WHERE channel_membership.channel_id = ? AND channel_role.editable = 1
    SQL
  end

  def self.get_all_roles(channel_id: nil)
    db.execute(<<-SQL, [channel_id])
      SELECT permission.name AS "permission_name", channel_role.name AS "role_name", channel_role.id AS "role_id"
      FROM channel_membership
      JOIN role_permission ON channel_membership.channel_role_id = role_permission.channel_role_id
	    JOIN channel_role ON channel_membership.channel_role_id = channel_role.id
      JOIN permission ON permission.id = role_permission.permission_id
      WHERE channel_membership.channel_id = ?
    SQL
  end

  def self.get_all_editable_roles(channel_id: nil)
    db.execute(<<-SQL, [channel_id])
      SELECT permission.name AS "permission_name", channel_role.name AS "role_name", channel_role.id AS "role_id"
      FROM channel_role
      LEFT JOIN role_permission ON channel_role.id = role_permission.channel_role_id
      LEFT JOIN permission ON permission.id = role_permission.permission_id
      WHERE channel_role.channel_id = ? AND editable = 1
    SQL
  end

  def self.create
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      channel_id INTEGER REFERENCES channel(id),
      editable BOOLEAN NOT NULL DEFAULT 1,
      name TEXT NOT NULL,
      UNIQUE(channel_id, name) -- Ensure no duplicate role names within a group
    SQL
  end
end
