if defined?(ActiveRecord)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
