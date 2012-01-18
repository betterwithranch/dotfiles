if defined?(Rails) && Rails.env
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
