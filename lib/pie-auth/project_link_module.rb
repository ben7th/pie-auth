module ProjectLinkModule
  URLS = {
    "user_auth"=>"http://2010.mindpin.com/",
    "discuss"=>"http://2010.mindpin.com/",
    "pin-workspace"=>"http://2010.mindpin.com/",
    "ui"=>"http://ui.mindpin.com/"
  }
  
  def pin_url_for(project_name,path=nil)
    if RAILS_ENV == "production"
      path ||= ""
      return File.join(find_site_by_name(project_name),path)
    end
    path ||= ""
    File.join(CoreService.project(project_name).url,path)
  end

  def find_site_by_name(project_name)
    URLS[project_name] || "http://unknow"
  end

end