require "json"
require "pathname"

class Ulist
  class Entry
    attr_reader :record, :cnt

    def initialize(hash_rec={})
      @record = hash_rec[:record]
      cnt = 1 unless hash_rec[:cnt]
    end

    def update(newrecord)
      if record.nil?
        record = newrecord
      else
        cnt += 1
        record = "#{record}, #{newrecord}"
      end
    end

    def to_hash
      {record: record, cnt: cnt}
    end
  end

  attr_reader :name
  attr_reader :path

  def initialize(name)
    @name = name
    @path = Pathname.new("data/#{name}.json")
  end

  def list_hash
    @list_hash ||= if path.file?
      hsh = JSON.parse(path.read)
      hsh.each { |k, v| hsh[k] = Entry.new(v) }
    else
      Hash.new { |h, k| h[k] = Entry.new }
    end
  end

  def update(key, value, upd=true)
    if upd
      list_hash[key].update(value)
    else
      list_hash[key] = Entry.new(value)
    end
  end

  def remove!(key)
    list_hash.delete(key)
  end

  # TODO update inject
  def to_hash
    list_hash.inject({}) do |h, (k, v)|
      h[k] = v.to_hash
  end

  def write!
    path.parent.mkpath
    File.open(path, "w") do |f|
      f.write(list_hash.to_hash.to_json)
    end
  end
end
