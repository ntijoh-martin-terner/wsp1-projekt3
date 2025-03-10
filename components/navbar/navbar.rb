# frozen_string_literal: true

require BASE_COMPONENT_PATH

class Navbar < BaseComponent
  def initialize(path_info: nil, user: nil, pages: { 'Home' => '/', 'About' => '/about' })
    @current_page_index = pages.values.find_index do |path|
      path == path_info || (path_info.start_with?(path) && path != '/')
    end || -1
    @user = user
    @pages = pages
    super()
  end
end
