class Preference < ActiveRecord::Base
  build_database_connection('user_auth')
end