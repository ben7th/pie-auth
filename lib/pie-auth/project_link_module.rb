module ProjectLinkModule
  URLS = {
    "production"=>{
      "user_auth"=>"http://2010.mindpin.com/",
      "discuss"=>"http://2010.mindpin.com/",
      "pin-workspace"=>"http://2010.mindpin.com/",
      "ui"=>"http://ui.mindpin.com/",
      "pin-bugs"=>"http://2010.mindpin.com/"},
    "development"=>{
      "user_auth"=>"http://dev.2010.mindpin.com/",
      "discuss"=>"http://dev.2010.mindpin.com/",
      "pin-workspace"=>"http://dev.2010.mindpin.com/",
      "ui"=>"http://dev.ui.mindpin.com/",
      "pin-bugs"=>"http://dev.2010.mindpin.com/"},
    "test"=>{
      "user_auth"=>"http://dev.2010.mindpin.com/",
      "discuss"=>"http://dev.2010.mindpin.com/",
      "pin-workspace"=>"http://dev.2010.mindpin.com/",
      "ui"=>"http://dev.ui.mindpin.com/",
      "pin-bugs"=>"http://dev.2010.mindpin.com/"}
  }
  
  def pin_url_for(project_name,path=nil)
    path ||= ""
    return File.join(find_site_by_name(project_name),path)
  end

  def find_site_by_name(project_name)
    site = URLS[RAILS_ENV][project_name]
    if site.blank?
      raise "没有 project_name 是 #{project_name} 的配置 "
    end
    site
  end

end