module SetReadonly
  def self.included(base)
    base.class_eval do
      alias :old_readonly? :readonly?
    end
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def set_readonly(boolean)
      return if RAILS_ENV == "test"
      define_method "readonly?" do
        return true if boolean
        old_readonly?
      end
    end
  end
end