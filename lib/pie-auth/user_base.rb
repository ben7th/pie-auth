require 'digest/sha1'
class UserBase < ActiveRecord::Base
  set_table_name 'users'
  set_readonly true

  def preference
    pref = Preference.find_by_user_id(self.id)
    pref = Preference.create(:user_id=>self.id) if pref.blank?
    return pref
  end

  # ���ݴ��������������������û���֤
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

  # ����������û��� ��֤
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

  # ���µ����ɸ������Լ�����Ϊ��֤������ش���
  # cookie��½�������õ��ļ����ַ���
  @@token_key='onlyecho'
  
  # ��֤cookies����
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

  # ʹ��SHA1�㷨�������ڲ���Կ���������������ܺ������
  private
  def self.encrypted_password(password,salt)
    string_to_hash = password + 'jerry_sun' + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  # ʹ��SHA1�㷨���������ַ���
  private
  def self.hashed_token_string(name,hashed_password)
    Digest::SHA1.hexdigest(name+hashed_password+@@token_key)
  end

end