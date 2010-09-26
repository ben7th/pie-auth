require 'digest/sha1'
class UserBase < ActiveRecord::Base
  set_readonly true
  build_database_connection(CoreService::USER_AUTH,{:table_name=>"users"})

  if RAILS_ENV == "test"
    LOGO_PATH_ROOT = "/tmp/"
    LOGO_URL_ROOT = "http://localhost"
  else
    SETTINGS = YAML.load(CoreService.project(CoreService::USER_AUTH).settings)
    LOGO_PATH_ROOT = SETTINGS["user_logo_file_path_root"]
    LOGO_URL_ROOT = SETTINGS["user_logo_file_url_root"]
  end

  # logo
  @logo_path = "#{LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @logo_url = "#{LOGO_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:styles => {:raw=>'500x500>',:medium=>"96x96#",:normal=>"48x48#",:tiny=>'32x32#',:mini=>'24x24#' },
    :path => @logo_path,
    :url => @logo_url,
    :default_url => "/images/logo/default_:class_:style.png",
    :default_style => :normal

  after_create :create_self_preference
  def create_self_preference
    preference
    return true
  end
  
  def preference
    pref = Preference.find_by_user_id(self.id)
    pref = Preference.create(:user_id=>self.id) if pref.blank?
    return pref
  end

  # 在线状态记录
  has_one :online_record,:dependent => :destroy

  # 是否激活
  def activated?
    !activated_at.blank?
  end

  # 根据传入的邮箱名和密码进行用户验证
  def self.authenticate(email,password)
    user=User.find_by_email(email)
    if user
      expected_password = encrypted_password(password,user.salt)
      if user.hashed_password != expected_password
        user=nil
      end
    end
    user
  end

  # 电子邮箱或用户名 认证
  def self.authenticate2(email_or_name,password)
    user = self.authenticate(email_or_name,password)
    if user.blank?
      users = User.find_all_by_name(email_or_name)
      users.each do |u|
        expected_password = encrypted_password(password,u.salt)
        if u.hashed_password == expected_password
          return u
        end
      end
    end
    return user
  end

  # 以下的若干个变量以及方法为认证部分相关代码
  # cookie登陆令牌中用到的加密字符串
  @@token_key='onlyecho'

  # 验证cookies令牌
  def self.authenticate_cookies_token(token)
    t=token.split(':')
    user=User.find_by_name(t[0])
    if user
      if t[2]!=hashed_token_string(user.name,user.hashed_password)
        user=nil
      end
    end
    user
  end

  # 使用SHA1算法，根据内部密钥和明文密码计算加密后的密码
  private
  def self.encrypted_password(password,salt)
    string_to_hash = password + 'jerry_sun' + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  # 使用SHA1算法生成令牌字符串
  private
  def self.hashed_token_string(name,hashed_password)
    Digest::SHA1.hexdigest(name+hashed_password+@@token_key)
  end

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :users, :force => true do |t|
      t.string   "name",                      :default => "", :null => false
      t.string   "hashed_password",           :default => "", :null => false
      t.string   "salt",                      :default => "", :null => false
      t.string   "email",                     :default => "", :null => false
      t.string   "sign"
      t.string   "activation_code"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "activated_at"
      t.string   "reset_password_code"
      t.datetime "reset_password_code_until"
      t.datetime "last_login_time"
    end
  end
end