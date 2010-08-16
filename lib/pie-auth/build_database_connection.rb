class ActiveRecord::Base
  def self.build_database_connection(name)
    config = YAML.load(CoreService.project(name).database)
    establish_connection(config[RAILS_ENV])
  end
end
