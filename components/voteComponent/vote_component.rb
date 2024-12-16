# frozen_string_literal: true

require BASE_COMPONENT_PATH

class VoteComponent < BaseComponent
  def initialize(path, votes = 0, user_vote = nil)
    @path = path
    @votes = votes
    super()
  end
end
