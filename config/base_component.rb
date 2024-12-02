class BaseComponent
  def initialize(data = {})
    @data = data
  end

  def render
    erb_path = File.join(self.class.component_path, 'template.erb')
    template = File.read(erb_path)
    ERB.new(template).result(binding)
  end

  def self.component_path
    const_source_location = Object.const_source_location(name)
    return File.dirname(const_source_location[0]) if const_source_location

    raise "Could not determine component path for #{name}"
  end
end
