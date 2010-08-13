require 'digest/sha1'
class UserBase < ActiveRecord::Base
  set_table_name 'users'
  set_readonly true

  def preference
    pref = Preference.find_by_user_id(self.id)
    pref = Preference.create(:user_id=>self.id) if pref.blank?
    return pref
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

end