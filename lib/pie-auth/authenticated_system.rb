module AuthenticatedSystem

  private
  # Returns true or false if the user is logged in.
  # Preloads @current_user with the user model if they're logged in.
  def logged_in?
    !!current_user
  end
  
  def admin_authorization
    logged_in? && current_user.name=='admin'
  end

  # Accesses the current user from the session. 
  # Future calls avoid the database because nil is not equal to false.
  def current_user
    @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || login_from_api) unless @current_user == false
  end

  # Store the given user id in the session.
  # 设定指定对象为当前会话用户对象，并将基本信息传入session保存
  def current_user=(user)
    session[:user_id] = user ? user.id : nil
    @current_user = user || false
  end
  
  # Check if the user is authorized
  #
  # Override this method in your controllers if you want to restrict access
  # to only a few actions or if you want to check if the user
  # has the correct rights.
  #
  # Example:
  #
  #  # only allow nonbobs
  #  def authorized?
  #    current_user.login != "bob"
  #  end
  def authorized?
    logged_in?
  end

  public
  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_filter :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_filter :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_filter :login_required
  #
  def login_required(info=nil)
    authorized? || access_denied(info)
  end

  private
  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied(info)
    respond_to do |format|
      format.html do
        store_location
        flash[:notice]=info
        redirect_to login_path
      end
      format.xml do
        # 进行app的认证
      end
      format.any do
        request_http_basic_authentication 'Web Password'
      end
    end
  end
  
  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.request_uri
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default,:status=>302)
    session[:return_to] = nil
  end
  
  # Inclusion hook to make #current_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in?, :admin_authorization
  end

  # Called from #current_user.  First attempt to login by the user id stored in the session.
  def login_from_session
    begin
      self.current_user = User.find(session[:user_id]) if session[:user_id]
    rescue
      nil
    end
  end

  # Called from #current_user.  Now, attempt to login by basic authentication information.
  def login_from_basic_auth
    authenticate_with_http_basic do |useremail, password|
      self.current_user = User.authenticate(useremail, password)
    end
  end

  # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
  def login_from_cookie
    if cookies[:token]
      user=User.authenticate_cookies_token(cookies[:token])
      if user
        self.current_user = user
      end
    end
  end

  def login_from_api
    begin
      user_id = request.headers['X-USERID']
      self.current_user = User.find(user_id)
    rescue
      nil
    end
  end
end
