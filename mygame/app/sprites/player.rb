class Player
  attr_sprite

  WIDTH = 40
  STANDING_HEIGHT = 40
  FLYING_HEIGHT = 20

  def initialize(grid, platform)
    mid_platform_x = (platform[:w] - platform[:x]) / 2

    @grid = grid
    @x = mid_platform_x - (WIDTH / 2)
    @y = platform[:y] + PlatformTile::TILE_SIZE
    @w = WIDTH
    @h = STANDING_HEIGHT
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
