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

    @args = args
    @x = platform.spawn_point.x - (SIZE / 2)
    @y = platform.spawn_point.y
    @w = SIZE
    @h = SIZE
    @flip_horizontally = false
    @path = 'sprites/square/blue.png'

    @velocity_x = 0
    @velocity_y = 0
    @decelerating = false
    @grounded = true
  end

  def move
    move_y
    move_x
  end

  def move_x
    case move_direction
    when :left
      @decelerating = @velocity_x > 0
      if @decelerating
        @velocity_x -= DECCELERATION_X
        @velocity_x = [0, @velocity_x].max
      else
        @velocity_x -= ACCELERATION_X
        @velocity_x = [-MAX_SPEED_X, @velocity_x].max
      end
    when :right
      @decelerating = @velocity_x < 0
      if @decelerating
        @velocity_x += DECCELERATION_X
        @velocity_x = [0, @velocity_x].min
      else
        @velocity_x += ACCELERATION_X
        @velocity_x = [MAX_SPEED_X, @velocity_x].min
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

    platform = platform_beside

    if platform.nil?
      @x += @velocity_x
      @x = @x - grid.right if @x >= grid.right
      @x = @x + grid.right if @x < 0
    else
      @x = @velocity_x > 0 ? platform.rect.left - @w : platform.rect.right
      @velocity_x *= -1
    end

    @flip_horizontally = facing_left?
  end

  def facing_left?
    @velocity_x < 0 || (@velocity_x == 0 && @flip_horizontally)
  end

  def move_y
    @velocity_y += jumped? ? ACCELERATION_Y : Game::GRAVITY

    if @velocity_y <= 0
      platform = platform_below

      if !platform.nil?
        @velocity_y = 0
        @h = SIZE
        @y = platform.rect.y + platform.rect.h
        @grounded = true
      else
        @y += @velocity_y
      end
    elsif @velocity_y > 0
      platform = platform_above
      if @grounded == true
        @h = SIZE / 2
        @y += SIZE / 2
        @grounded = false
      end

      if @y + @h + @velocity_y >= grid.top
        @y = grid.top - @h
        @velocity_y *= -0.8
      elsif !platform.nil?
        @velocity_y *= -0.5
        @y = platform.rect.y - @h
      else
        @y += @velocity_y
      end
    end
  end

  def platform_below
    platforms_below = state.platforms.find_all { |platform| platform.rect.top <= rect.bottom }
    y_collision_pos = @y + @velocity_y
    y_collision_pos -= SIZE / 2 if !@grounded

    find_collision(
      platforms_below,
      rect.merge(y: y_collision_pos.floor, h: SIZE)
    )
  end

  def platform_above
    platforms_above = state.platforms.find_all { |platform| platform.rect.bottom >= rect.top }
    find_collision(platforms_above, (rect.merge y: (@y + @velocity_y).ceil))
  end

  def platform_beside
    x_pos = @x + @velocity_x
    x_pos = x_pos.ceil if @velocity_x > 1
    x_pos = x_pos.floor if @velocity_x < 1

    platforms_beside = state.platforms.find_all do |platform|
      if @velocity_x > 0
        platform.rect.left >= rect.right
      else
        platform.rect.right <= rect.left
      end
    end
    find_collision(platforms_beside, (rect.merge x: x_pos))
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

  def rect
    [@x.floor, @y.floor, @w, @h].rect.to_hash
  end

  def serialize
    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      flip_horizontally: @flip_horizontally,
      path: @path,
      velocity_x: @velocity_x,
      velocity_y: @velocity_y,
      decelerating: @decelerating
    }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
