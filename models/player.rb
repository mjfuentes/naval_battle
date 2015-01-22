class Player
  attr_accessor :name,:username,:id
  @password;

  def initialize(name,username, password)
    @name = name
    @username = username
    @password = password
    @id = save_player
  end
  
  def save_player
    #TODO save to DB ###
    1
  end
  
  def to_a
    [id, name]
  end

end