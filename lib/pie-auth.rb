module PieAuth
  class << self
    def auth_include_modules
      require 'pie-auth/set_readonly'
      ActiveRecord::Base.send :include, SetReadonly
      require 'pie-auth/build_database_connection'
      ActiveRecord::Base.send :include, BuildDatabaseConnection
    end
  end
end

if defined? Rails
  PieAuth.auth_include_modules if defined? ActiveRecord::Base
end

require 'pie-auth/authenticated_system'
require 'pie-auth/core_service'
CoreService.reset_config
require 'pie-auth/preference'
require 'pie-auth/user_base'