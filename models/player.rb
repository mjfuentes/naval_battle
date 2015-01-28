require 'active_record'

class Player < ActiveRecord::Base
  attr_accessor :name,:username,:id
  @password;

  def initialize(name,username, password)
    @name = name
    @username = username
    @password = password
  end
  
  def to_a
    [id, name]
  end

end