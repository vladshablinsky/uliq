require "json"
require "pathname"
require_relative "config"

class Ulist
  class Entry
    attr_accessor :record, :cnt

    def initialize(hash_rec={})
      @record = hash_rec[:record] || hash_rec["record"]
      @cnt = (hash_rec[:cnt] || hash_rec["cnt"] || 1)
    end

    def self.for_value(value)
      Entry.new({ record: value, cnt: 1 })
    end

    def update(newrecord, concat=false)
      if @record.nil?
        @record = newrecord
      else
        @cnt += 1
        @record = "#{@record}, #{newrecord}" if concat
      end
    end

    def to_s
      record
    end

    def to_hash
      {record: record, cnt: cnt}
    end
  end

  attr_reader :name
  attr_reader :path

  def initialize(name)
    @name = name
    @path = ULIQ_DATA_PATH.join("#{@name}.json")
  end

  def self.from_file(file)
    Ulist.new(File.basename(".json"))
  end

  def list_hash
    @list_hash ||= if path.file?
      hsh = JSON.parse(path.read)
      hsh.each { |k, v| hsh[k] = Entry.new(v) }
    else
      {}
    end
  end

  def update(key, value)
    if list_hash[key]
      list_hash[key].update(value)
    else
      list_hash[key] = Entry.for_value(value)
    end
  end

  def remove!(key)
    list_hash.delete(key)
  end

  # TODO update inject
  def to_hash
    Hash[list_hash.map{ |k, v| [k, v.to_hash] }]
  end

  def print
    list_hash.each do |k, v|
      puts "#{k} -- #{v.record} (#{v.cnt})"
    end
  end

  def write!
    path.parent.mkpath
    to_write = to_hash.to_json
    File.open(path, "w") do |f|
      f.write(to_write)
    end
    puts "#{path} written"
  end
end
