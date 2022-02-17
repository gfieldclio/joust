class Player
  attr_gtk
  attr_sprite

  SIZE = 40

  def initialize(args)
    platform = args.state.platforms.first
    mid_platform_x = (platform.rect[:w] - platform.rect[:x]) / 2

    @args = args
    @x = mid_platform_x - (SIZE / 2)
    @y = platform.rect[:y] + PlatformTile::TILE_SIZE
    @w = SIZE
    @h = SIZE
    @path = 'sprites/square/blue.png'

    @velocity_x = 0
    @velocity_y = 0
  end

  def move
    @velocity_y += Game::GRAVITY
    @velocity_y = 0 if platform_below?

    @y += @velocity_y
  end

  def platform_below?
    return false unless @velocity_y <= 0

    platforms_below = state.platforms { |platform| platform.rect.top <= player.y }
    collision?(platforms_below, (rect_with_legs.merge y: rect_with_legs.y + @velocity_y))
  end

  def collision?(entities, target)
    entities.find do |e|
      e.rect.intersect_rect?(target)
    end
  end

  def rect_with_legs
    { x: @x, y: @y, w: @w, h: @h }
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
