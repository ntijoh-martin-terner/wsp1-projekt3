require BASE_MODEL_PATH
require 'fileutils'
require 'open3'

class MediaModel < BaseModel
  def self.table_name
    @table_name ||= 'media'
  end

  def self.create
    # Static method to fetch pseudo-random posts
    super(<<-SQL)
      id INTEGER PRIMARY KEY,
      post_id INTEGER REFERENCES post(id) ON DELETE CASCADE, -- Links to the post
      media_url TEXT NOT NULL CHECK (media_url <> ''), -- Media URL cannot be empty
      low_res_url TEXT, -- Low-res variant for quick loading
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Attachment creation time
    SQL
  end

  # Adds uploaded media to the database
  def self.add_media(post_id: nil, file: nil, upload_dir: nil)
    return unless file

    # Ensure upload directory exists
    FileUtils.mkdir_p(upload_dir)

    # Extract filename and file extension
    filename = SecureRandom.hex(8) + File.extname(file[:filename]).downcase
    filepath = File.join(upload_dir, filename)

    # Write file to disk
    File.open(filepath, 'wb') { |f| f.write(file[:tempfile].read) }

    # Calculate relative URL for serving the file
    relative_url = File.join('/uploads', filename)

    # Process the file based on its type
    low_res_url = case File.extname(filename)
                  when '.jpg', '.jpeg', '.png', '.gif'
                    process_image(filepath)
                  when '.mp4'
                    process_video(filepath, upload_dir)
                  else
                    puts "Unsupported file type: #{file[:filename]}"
                    return
                  end

    # Insert the media record into the database
    insert({
             post_id: post_id,
             media_url: relative_url, # Use low_res_url if available; fallback to original
             low_res_url: low_res_url,
             created_at: Time.now.to_s
           })
  end

  # Process and resize an image, create low-res version
  def self.process_image(filepath)
    low_res_path = filepath.sub(/(\.\w+)$/, '_lowres\1')

    # Resize original image to max 1920x1080
    Open3.capture2e("convert #{filepath} -resize '1920x1080>' #{filepath}")

    # Create a smaller low-res version (e.g., 480px wide)
    Open3.capture2e("convert #{filepath} -resize 480 #{low_res_path}")

    low_res_path
  end

  # Process video: chunk for streaming and create a low-res variant
  def self.process_video(filepath, upload_dir)
    base_name = File.basename(filepath, '.mp4')
    output_dir = File.join(upload_dir, base_name)
    FileUtils.mkdir_p(output_dir)

    # Chunk the video for streaming
    chunk_video(filepath, output_dir)

    nil
  end

  # Break a video into segments for streaming
  def self.chunk_video(filepath, output_dir)
    m3u8_path = File.join(output_dir, 'index.m3u8')
    Open3.capture2e(<<-FFMPEG)
      ffmpeg -i #{filepath} -codec: copy -start_number 0 \
        -hls_time 10 -hls_list_size 0 -f hls #{m3u8_path}
    FFMPEG
  end
end
