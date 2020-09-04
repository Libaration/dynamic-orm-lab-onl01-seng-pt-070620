require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  def initialize(opts = {})
    opts.compact.each{|key, value| self.send("#{key}=",value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names[1..-1].join(', ')
  end

  def values_for_insert
    self.class.column_names.collect{|col| "'#{send(col)}'" unless send(col).nil?}.compact.join(', ')
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute('SELECT last_insert_rowid()').first["last_insert_rowid()"]
  end

  def self.table_name
    self.name.downcase + "s"
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM #{table_name}
    WHERE name = ?
    SQL
    DB[:conn].execute(sql,name)
  end

  def self.find_by(opts = {})
    sql = <<-SQL
    SELECT *
    FROM #{table_name}
    WHERE "#{opts.keys.first.to_s}" IS "#{opts.values.first.to_s}"
    SQL
    DB[:conn].execute(sql)
  end

  def self.column_names
    sql = <<-SQL
      PRAGMA TABLE_INFO('#{self.table_name}')
    SQL
    DB[:conn].execute(sql).collect{|column| column["name"]}
  end
end