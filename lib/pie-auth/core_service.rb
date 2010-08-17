class CoreService < ActiveResource::Base

  PROJECT_CONFIG = YAML.load_file(Rails.root.join("config/project_config.yml"))[RAILS_ENV]
  MASTER_NAME = "user_auth"
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
      YAML.load_file(Rails.root.join("config/database.yml"))[RAILS_ENV]
    end
  
    def project(project_name)
      return self.new(:name=>self.name,:url=>self.url,:database=>nil,:settings=>PROJECT_CONFIG) if RAILS_ENV == "test"
      # 如果是管理配置文件的工程，则直接从数据库中获取配置信息
      return find_or_create_master_config if is_master?
      CoreService.find(project_name)
    end

    def reset_config
      return find_or_create_master_config if is_master?
      post(:reset_config, :project => {:settings => PROJECT_CONFIG,:database=> database})
    end

    def find_or_create_master_config
      pj = ProjectConfig.find_by_name(name)
      return ProjectConfig.create!(:name=>name,:url=>url,:database=>database,:settings=>PROJECT_CONFIG).reload if pj.blank?
      return pj.reload if pj.update_attributes!(:url=>url,:database=>database,:settings=>PROJECT_CONFIG)
    end

    # 判断这个工程 是不是  管理工程
    def is_master?
      url == master_url
    end
  end
end
