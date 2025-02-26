# frozen_string_literal: true

require BASE_COMPONENT_PATH

class Navbar < BaseComponent
  def initialize(path_info: nil, user: nil, pages: { 'Home' => '/', 'About' => '/about' })
    @current_page_index = pages.values.index(path_info) || -1
    @user = user
    @pages = pages
    super()
  end
end
