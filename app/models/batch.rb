class Batch < ActiveRecord::Base
  attr_accessible :name
  has_many :projects, :dependent=>:destroy
end
