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
    alias :show_moped :show_mongo
end
