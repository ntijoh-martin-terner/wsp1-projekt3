# frozen_string_literal: true

require BASE_COMPONENT_PATH

class TabComponent < BaseComponent
  def initialize(path_info: nil, tabs_name: 'Tabs Name', query: '', tabs: { 'Home' => '/', 'About' => '/about' })
    @tabs_name = tabs_name
    @tabs = tabs
    @query = query
    # Extract only the path, ignoring the query string
    clean_path = URI(path_info).path if path_info

    @current_page_index = tabs.values.index(clean_path) || 0
    super()
  end
end
