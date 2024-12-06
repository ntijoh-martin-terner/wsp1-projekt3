# frozen_string_literal: true

require BASE_COMPONENT_PATH

class Profile < BaseComponent
  def initialize(user, dropdown = true)
    super()
    @name = user['username']
    @mail = user['mail']
    @dropdown = dropdown
    profile_picture_id = user['profile_picture_id']
    @profile_picture_src = profile_picture_id ? "/img/profile_pictures/#{profile_picture_id}" : nil
  end
end
