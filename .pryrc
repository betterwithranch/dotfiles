if defined?(ActiveRecord)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

#
# Usage:
#     > show_mongo

#if defined?(Rails::Console)
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
#end
if defined?(PryByebug) || defined?(PryNav)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
end   

if defined?(PryByebug)
  Pry.commands.alias_command 'f', 'finish'
end

Pry::Commands.command(/^$/, "repeat last command") do
  _pry_.run_command Pry.history.to_a.last
end
