require_relative "ulist"
require "pathname"

class UlistController
  class UlistControllerParseError < RuntimeError
    def initialize(option)
      super("can't execute with #{option}, read help")
    end
  end

  attr_reader :options

  def initialize(options)
    @options = options
  end

  def search_list(list, key)
    if val = list.list_hash[key]
      puts val
      puts "#{key.upcase} -- #{val.record} (cnt: #{val.cnt})"
    end
  end

  def proceed
    if options[:search]
      raise UlistControllerParseError, :key unless options[:key]
      if list = options[:list]
        puts "searching..."
        search_list(Ulist.new(list), options[:key])
      else
        ulists.each do |list|
          puts "searching in #{list.name}..."
          search_list(list, options[:key])
        end
      end
    elsif options[:add]
      raise UlistControllerParseError, :list unless options[:list]
      raise UlistControllerParseError, :key unless options[:key]
      raise UlistControllerParseError, :value unless options[:value]

      list = Ulist.new(options[:list])
      key, value = options[:key], options[:value]
      list.update(key, value)
      puts "#{list.name} now has #{list.list_hash[key]}"
      list.write!
    elsif options[:new]
      raise UlistControllerParseError, :list unless options[:list]
      list = Ulist.new(options[:list])
      list.write!
    elsif options[:lists]
      ulists.each { |list| print list }
    end
  end

  def ulists
    @ulists ||= Dir["data/*"].select do |f|
      next unless File.file? f
      Ulist.from_file(f)
    end
  end
end
