class Player
  attr_accessor :name, :id
  @password;

  def initialize(name, password)
    @name = name
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