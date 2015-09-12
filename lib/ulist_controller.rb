require_relative "ulist"
require "pathname"

class UlistController
  class UlistControllerParseError < RuntimeError
    def initialize(option)
      super("can't execute with #{option.to_s}, it's probably missed, read help")
    end
  end

  attr_reader :options

  def initialize(options)
    @options = options
  end

  def ulist
    @ulist ||= if options[:list]
                Ulist.new(options[:list])
              else
                Ulist.new(ULIQ_DEFAULT_LIST)
              end

    raise UlistControllerParseError, :list unless @ulist

    @ulist
  end

  def key
    @key ||= options[:key]
    raise UlistControllerParseError, :key unless @key

    @key
  end

  def value
    @value ||= options[:value]
    raise UlistControllerParseError, :value unless @value

    @value
  end

  def search_list(list, key)
    if val = list.list_hash[key]
      puts val
      puts "#{key.upcase} -- #{val.record} (cnt: #{val.cnt})"
    end
  end


  def proceed
    if options[:search]
      begin
        puts "searching..."
        search_list(ulist, key)
      rescue UlistControllerParseError
        # TODO
        # - search through all the list if no list given
      end
    elsif options[:add]
      ulist.update(key, value)
      puts "\"#{ulist.name}\" now has #{ulist.list_hash[key].record}"
      ulist.write!
    elsif options[:new]
      ulist.write!
    elsif options[:show]
      ulists.each do |list|
        puts list.name
        list.print
        puts "=" * 80
      end
    end
  end

  def ulists
    @ulists ||= Dir["#{ULIQ_DATA_PATH}/*"].select do |f|
      next unless File.file? f
      Ulist.from_file(f)
    end
  end
end
