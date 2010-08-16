class CoreService < ActiveResource::Base

  PROJECT_CONFIG = YAML.load_file(Rails.root.join("config/project_config.yml"))[RAILS_ENV]
  self.site = PROJECT_CONFIG["master_url"]

  def self.project(project_name)
    # 如果是管理配置文件的工程，则直接从数据库中获取配置信息
    if defined?(IS_MASTER_PROJECT) && IS_MASTER_PROJECT
      return ProjectConfig.find_by_name(project_name)
    end
    CoreService.find(project_name)
  end

  def self.reset_config
    self.post(:reset_config, :project => {
        :settings => PROJECT_CONFIG,
        :database=> YAML.load_file(Rails.root.join("config/database.yml"))
      })
  end

end
