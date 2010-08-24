module ProjectLinkModule
  def pin_url_for(project_name,path)
    File.join(CoreService.project(project_name).url,path)
  end
end
