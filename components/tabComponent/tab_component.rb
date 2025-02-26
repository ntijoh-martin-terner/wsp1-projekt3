# frozen_string_literal: true

require BASE_COMPONENT_PATH

class TabComponent < BaseComponent
  def initialize(path_info: nil, tabs_name: 'Tabs Name', tabs: { 'Home' => '/', 'About' => '/about' })
    @tabs_name = tabs_name
    @tabs = tabs
    @current_page_index = tabs.values.index(path_info) || 0
    super()
  end
end
