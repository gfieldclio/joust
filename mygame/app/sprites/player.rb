class Player
  attr_gtk
  attr_sprite

  SIZE = 40
  ACCELERATION_X = 0.2
  DECCELERATION_X = 0.3
  MAX_SPEED_X = 10

  def initialize(args)
    platform = args.state.platforms.first
    mid_platform_x = (platform.rect[:w] - platform.rect[:x]) / 2

    @args = args
    @x = mid_platform_x - (SIZE / 2)
    @y = platform.rect[:y] + PlatformTile::TILE_SIZE
    @w = SIZE
    @h = SIZE
    @flip_horizontally = false
    @path = 'sprites/square/blue.png'

    @velocity_x = 0
    @velocity_y = 0
    @decelerating = false
  end

  def move
    move_x
    move_y
  end

  def move_x
    case move_direction
    when :left
      @decelerating = @velocity_x > 0
      @velocity_x -= @decelerating ? DECCELERATION_X : ACCELERATION_X
      @velocity_x = [-MAX_SPEED_X, @velocity_x].max
      @flip_horizontally = !@decelerating
    when :right
      @decelerating = @velocity_x < 0
      @velocity_x += @decelerating ? DECCELERATION_X : ACCELERATION_X
      @velocity_x = [MAX_SPEED_X, @velocity_x].min
      @flip_horizontally = @decelerating
    else
      if @decelerating
        if @velocity_x > 0
          @velocity_x = [@velocity_x - DECCELERATION_X, 0].max
        else
          @velocity_x = [@velocity_x + DECCELERATION_X, 0].min
        end
      end
    end

    @x += @velocity_x
  end

  def move_y
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

  def move_direction
    if inputs.left && !inputs.right
      :left
    elsif inputs.right && !inputs.left
      :right
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
