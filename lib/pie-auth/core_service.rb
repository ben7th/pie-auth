class CoreService < ActiveResource::Base

  PROJECT_CONFIG = YAML.load_file(Rails.root.join("config/project_config.yml"))[RAILS_ENV]
  USER_AUTH = "user_auth"
  self.site = PROJECT_CONFIG["master_url"]

  class << self
    def name
      PROJECT_CONFIG['name']
    end

    def url
      PROJECT_CONFIG['url']
    end
  
    def master_url
      PROJECT_CONFIG['master_url']
    end

    def database
      database_path = File.join(Rails.root,"config/database.yml")
      if File.exist?(database_path)
        return YAML.load_file(database_path)[RAILS_ENV]
      end
      return {}
    end
  
    def project(project_name)
      #      return self.new(:name=>self.name,:url=>self.url,:database=>nil,:settings=>PROJECT_CONFIG) if RAILS_ENV == "test"
      CoreService.find(project_name)
    end

    def reset_config
      begin
        return if RAILS_ENV == "test"
        post(:reset_config, :project => {:settings => PROJECT_CONFIG,:database=> database})
      rescue Exception => ex
        raise %`
        "#{ex}"
        post_site is #{self.site}
        `
      end
    end

  end
end
