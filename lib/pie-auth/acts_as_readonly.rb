module ActsAsReadonly
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def acts_as_readonly(boolean)
      if boolean
        define_method "readonly?" do
          true
        end
      else
        define_method "readonly?" do
          old_readonly?
        end
      end
    end
  end
end

class ActiveRecord::Base
  alias :old_readonly? :readonly?
  include ActsAsReadonly
end