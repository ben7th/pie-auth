class Preference < ActiveRecord::Base
  build_database_connection(CoreService::MASTER_NAME)
end