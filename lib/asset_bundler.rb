# frozen_string_literal: true

require 'terser' # JS compression
require 'sassc'  # CSS compression

class AssetBundler
  def initialize
    @js_groups = {}
    @css_groups = {}
    @js_cache = {}
    @css_cache = {}
  end

  # Define a new JavaScript group with paths and compress flags
  def add_js(group, paths:)
    @js_groups[group] = paths.map { |path, compress| { path: path, compress: compress } }
  end

  # Define a new CSS group with paths and compress flags
  def add_css(group, paths:)
    @css_groups[group] = paths.map { |path, compress| { path: path, compress: compress } }
  end

  # Bundle and optionally minify JavaScript files for a group
  def bundle_js(group)
    raise "JavaScript group '#{group}' not defined" unless @js_groups.key?(group)

    return @js_cache[group] if @js_cache.key?(group)

    combined_content = @js_groups[group].map do |file|
      content = read_file(file[:path])
      file[:compress] ? Terser.compile(content) : content
    end.join("\n")

    @js_cache[group] = combined_content
  end

  # Bundle and optionally minify CSS files for a group
  def bundle_css(group)
    raise "CSS group '#{group}' not defined" unless @css_groups.key?(group)

    return @css_cache[group] if @css_cache.key?(group)

    combined_content = @css_groups[group].map do |file|
      content = read_file(file[:path])
      file[:compress] ? SassC::Engine.new(content, style: :compressed).render : content
    end.join("\n")

    @css_cache[group] = combined_content
  end

  # Clear both JS and CSS caches
  def clear_cache
    @js_cache.clear
    @css_cache.clear
  end

  private

  # Helper to read file content
  def read_file(path)
    raise "File not found: #{path}" unless File.exist?(path)

    File.read(path)
  end
end
