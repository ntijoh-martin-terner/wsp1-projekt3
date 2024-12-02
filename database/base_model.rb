class BaseModel
  def self.table_name
    @table_name ||= name.downcase
  end

  # maybe make the database stuff be passed from another class so that every model doesn't create its own database
  def self.db
    return @db if @db

    @db = SQLite3::Database.new(DATABASE_FILE_PATH)
    @db.results_as_hash = true
    @db.execute('PRAGMA foreign_keys = ON')

    @db
  end

  @primary_keys = db.execute("PRAGMA table_info(#{table_name})").filter_map do |column|
    column['name'] if column['pk'] == 1
  end

  # Helper to build WHERE clause for primary key(s)
  def self.primary_key_clause
    @primary_keys.map { |key| "#{key} = ?" }.join(' AND ')
  end

  def self.drop
    db.execute("DROP TABLE IF EXISTS #{table_name}")
  end

  # Insert data into the table
  def self.insert(data)
    columns = data.keys.join(', ')
    placeholders = Array.new(data.keys.size, '?').join(', ')
    values = data.values

    db.execute(<<-SQL, values)
      INSERT INTO #{table_name} (#{columns})
      VALUES (#{placeholders});
    SQL
  end

  def self.create(data)
    db.execute(<<-SQL)
      CREATE TABLE #{table_name} (
        #{data}
      );
    SQL

    @primary_keys = db.execute("PRAGMA table_info(#{table_name})").filter_map do |column|
      column['name'] if column['pk'] == 1
    end
  end
end
