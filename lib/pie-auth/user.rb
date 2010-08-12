class User < ActiveRecord::Base
  acts_as_readonly true
end