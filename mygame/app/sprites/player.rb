class Player
  attr_sprite

  def initialize(grid)
    @grid = grid
    @x = 620
    @y = 340
    @w = 40
    @h = 40
    @path = 'sprites/square/blue.png'
  end

  def move
  end

  def serialize
    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: @path
    }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
