module SetReadonly
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def set_readonly(boolean)
      define_method "readonly?" do
        return true if boolean
        old_readonly?
      end
    end
  end
end

class ActiveRecord::Base
  alias :old_readonly? :readonly?
  include SetReadonly
end