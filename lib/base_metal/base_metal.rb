#require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

# MindPin BaseMetal 0.2
# updated_at 2010.7.22
# used for Rack

class BaseMetal
  def self.call(env)
    self.fix_path_info(env)
    begin
      self.check_routes(env)
    rescue Exception => ex
      self.request_error
    end
  end

  def self.fix_path_info(env)
    env["PATH_INFO"], env["QUERY_STRING"] = env["REQUEST_URI"].split(/\?/, 2)
  end

  def self.check_routes(env)
    routes_match_hash = self.routes_match(env)
    if routes_match_hash
      return self.process_request(routes_match_hash)
    end
    self.request_pass
  end

  def self.process_request(hash)
    self.handle(hash)
  ensure
    ActiveRecord::Base.clear_active_connections!
  end

  def self.handle(hash)
    action = hash[:action]
    eval "self.#{action}(hash)"
  end

  def self.routes_match(env)
    routes = self._prepare_routes
    routes.each do |route|
      method = route[:method]
      regexp = route[:regexp]
      action = self._get_action(route)

      match = env["REQUEST_URI"].match(regexp)
      method_match = env['REQUEST_METHOD'] == method

      return {:url_match=>match,:action=>action,:env=>env} if (match && method_match)
    end
    return false
  end

  # self.routes可能有两种情况
  # {:method=>'GET',...} Hash
  # [{...},{...}] Array
  # 需要统一化成数组，便于后面处理
  def self._prepare_routes
    [self.routes].flatten
  end

  def self._get_action(route)
    route[:action] || :deal
  end

  def self.request_pass
    [404, {"Content-Type" => "text/html"}, ["Not Found"]]
  end

  def self.request_error
    [500, {"Content-Type" => "text/html"}, ["Error"]]
  end

end
