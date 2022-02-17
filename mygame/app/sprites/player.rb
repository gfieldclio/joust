class Player
  attr_gtk
  attr_sprite

  SIZE = 40
  ACCELERATION_X = 0.2
  DECCELERATION_X = 0.3
  ACCELERATION_Y = 3
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
      if @decelerating
        @velocity_x -= DECCELERATION_X
        @velocity_x = [0, @velocity_x].max
        @flip_horizontally = false
      else
        @velocity_x -= ACCELERATION_X
        @velocity_x = [-MAX_SPEED_X, @velocity_x].max
        @flip_horizontally = true
      end
    when :right
      @decelerating = @velocity_x < 0
      if @decelerating
        @velocity_x += DECCELERATION_X
        @velocity_x = [0, @velocity_x].min
        @flip_horizontally = true
      else
        @velocity_x += ACCELERATION_X
        @velocity_x = [MAX_SPEED_X, @velocity_x].min
        @flip_horizontally = false
      end
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
    @x = @x - grid.right if @x > grid.right
    @x = @x + grid.right if @x < 0
  end

  def move_y
    @velocity_y += jumped? ? ACCELERATION_Y : Game::GRAVITY

    if @velocity_y < 0
      platform = platform_below

      if !platform.nil?
        @velocity_y = 0
        @y = platform.rect.y + platform.rect.h
      else
        @y += @velocity_y
      end
    elsif @velocity_y > 0
      platform = platform_above

      if @y + @h + @velocity_y >= grid.top
        @y = grid.top - @h
        @velocity_y *= -0.8
      elsif !platform.nil?
        @velocity_y *= -0.5
        @y = platform.rect.y - @h
      else
        @y += @velocity_y
      end
    else
      @y += @velocity_y
    end
  end

  def platform_below
    platforms_below = state.platforms { |platform| platform.rect.top <= bottom }
    find_collision(platforms_below, (rect_with_legs.merge y: rect_with_legs.y + @velocity_y))
  end

  def platform_above
    platforms_above = state.platforms { |platform| platform.rect.bottom >= top }
    find_collision(platforms_above, (rect_with_legs.merge y: rect_with_legs.y + @velocity_y))
  end

  def find_collision(entities, target)
    entities.find do |e|
      e.rect.intersect_rect?(target)
    end
  end

  def jumped?
    args.inputs.controller_one.key_down.a || args.inputs.keyboard.key_down.space || args.inputs.keyboard.key_down.c
  end

  def move_direction
    if inputs.left && !inputs.right
      :left
    elsif inputs.right && !inputs.left
      :right
    end
  end

  def top
    @y + @h
  end

  def bottom
    @y
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
