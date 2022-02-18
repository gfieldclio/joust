class PlatformTile
  attr_sprite

  TILE_SIZE = 20

  WALL_LEFT_PATH = 'sprites/tile/wall-1011.png'.freeze
  WALL_MIDDLE_PATH = 'sprites/tile/wall-1010.png'.freeze
  WALL_RIGHT_PATH = 'sprites/tile/wall-1110.png'.freeze

  def initialize(grid, x, y, path=WALL_MIDDLE_PATH, spawn_point=false)
    @grid = grid
    @x = x
    @y = y
    @w = TILE_SIZE
    @h = TILE_SIZE
    @path = path

    if spawn_point
      @r = 0
      @g = 255
      @b = 255
    end
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
