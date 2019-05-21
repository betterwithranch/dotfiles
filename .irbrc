if defined?(ActiveRecord)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

#
# Usage:
#     > show_mongo

if defined?(Rails::Console)
  def show_mongo
    if Moped.logger == Rails.logger
      Moped.logger = Logger.new($stdout)
      true
    else
      Moped.logger = Rails.logger
      false
    end
  end
  alias show_moped show_mongo
end

if defined?(::Bundler)
  global_gemset = ENV['GEM_PATH'].split(':').grep(/ruby.*@global/).first
  if global_gemset
    all_global_gem_paths = Dir.glob("#{global_gemset}/gems/*")
    all_global_gem_paths.each do |p|
      gem_path = "#{p}/lib"
      $LOAD_PATH << gem_path
    end
  end
end

# Use Pry everywhere
require "rubygems"
require 'pry'
Pry.start
exit
