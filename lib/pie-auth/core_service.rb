class CoreService < ActiveResource::Base

  PROJECT_CONFIG = YAML.load_file(Rails.root.join("config/project_config.yml"))[RAILS_ENV]
  self.site = PROJECT_CONFIG["master_url"]

  def self.name
    PROJECT_CONFIG['name']
  end

  def self.url
    PROJECT_CONFIG['url']
  end

  def self.database
    YAML.load_file(Rails.root.join("config/database.yml"))
  end
  
  def self.project(project_name)
    # 如果是管理配置文件的工程，则直接从数据库中获取配置信息
    if defined?(IS_MASTER_PROJECT) && IS_MASTER_PROJECT
      return self.find_or_create_master_config
    end
    CoreService.find(project_name)
  end

  def self.reset_config
    if defined?(IS_MASTER_PROJECT) && IS_MASTER_PROJECT
      return self.find_or_create_master_config
    end
    self.post(:reset_config, :project => {:settings => PROJECT_CONFIG,:database=> self.database})
  end

  def self.find_or_create_master_config
    pj = ProjectConfig.find_by_name(self.name)
    return ProjectConfig.create!(:name=>self.name,:url=>self.url,:database=>self.database).reload if pj.blank?
    return pj.reload if pj.update_attributes!(:url=>self.url,:database=>self.database)
  end
  
end
