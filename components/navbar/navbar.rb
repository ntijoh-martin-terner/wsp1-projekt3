# frozen_string_literal: true

require BASE_COMPONENT_PATH

class Navbar < BaseComponent
  def initialize(current_page = 0, user = nil, pages = {'Home' => '/', 'About' => '/about'})
    @current_page = current_page
    @user = user
    @pages = pages
    super()
  end
end
