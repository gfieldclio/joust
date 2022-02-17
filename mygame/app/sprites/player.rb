class Player
  attr_sprite

  SIZE = 40

  def initialize(grid, platform)
    mid_platform_x = (platform[:w] - platform[:x]) / 2

    @grid = grid
    @x = mid_platform_x - (SIZE / 2)
    @y = platform[:y] + PlatformTile::TILE_SIZE
    @w = SIZE
    @h = SIZE
    @path = 'sprites/square/blue.png'

    @velocity_x = 0
    @velocity_y = 0
  end

  def move
    @velocity_y += Game::GRAVITY
    @y += @velocity_y
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
