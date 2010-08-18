class Preference < ActiveRecord::Base
  build_database_connection(CoreService::USER_AUTH)

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :preferences, :force => true do |t|
      t.integer  "user_id",                          :null => false
      t.boolean  "auto_popup_msg", :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "show_tooltip",   :default => true
      t.string   "theme"
    end
  end
end