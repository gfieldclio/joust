class Player
  attr_gtk
  attr_sprite

  SIZE = 40
  ACCELERATION_GROUNDED_X = 1
  DECCELERATION_GROUNDED_X = 0.3
  ACCELERATION_AIRBORN_X = 0.1
  ACCELERATION_Y = 3
  MAX_SPEED_X = 10

  KEYBOARD_SPRITE_PATH = 'sprites/square/blue.png'
  CONTROLLER_ONE_SPRITE_PATH = 'sprites/square/green.png'
  CONTROLLER_TWO_SPRITE_PATH = 'sprites/square/white.png'

  attr_accessor :controller

  def initialize(args, controller)
    @args = args
    @controller = controller

    spawn_point = pick_spawn_point
    @x = spawn_point.x
    @y = spawn_point.y
    @w = SIZE
    @h = SIZE
    @flip_horizontally = false
    @path = Player.const_get("#{@controller.upcase}_SPRITE_PATH")

    @velocity_x = 0
    @velocity_y = 0
    @decelerating = false
    @grounded = true
    @move_start = 0
  end

  def pick_spawn_point
    spawn_point = args.state.platforms
      .find_all { |platform| !platform.spawn_point.nil? }
      .map(&:spawn_point)
      .find_all do |spawn_point|
        state.players.none? { |player| geometry.distance(spawn_point, player.rect) <= 100 }
      end
      .sample

    [
      spawn_point.x - (SIZE / 2).to_i,
      spawn_point.y
    ].point.to_hash
  end

  def move
    move_y
    move_x
  end

  def move_y
    @velocity_y += jumped? ? ACCELERATION_Y : Game::GRAVITY

    if @velocity_y <= 0
      platform = platform_below

      if !platform.nil?
        land(platform)
      else
        @y += @velocity_y
        take_flight
      end
    elsif @velocity_y > 0
      platform = platform_above
      take_flight

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

  def land(platform)
    @velocity_y = 0
    @h = SIZE
    @y = platform.rect.y + platform.rect.h
    @grounded = true
  end

  def take_flight
    if @grounded == true
      @h = SIZE / 2
      @y += SIZE / 2
      @grounded = false
    end
  end

  def move_x
    move_x_grounded if @grounded
    move_x_airborn if !@grounded
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

  def move_x_grounded
    case move_direction
    when :left
      @decelerating = @velocity_x > 0
      if @decelerating
        @velocity_x -= DECCELERATION_GROUNDED_X
        @velocity_x = [0, @velocity_x].max
      elsif ((@move_start - state.tick_count) % 5) == 0
        @velocity_x -= ACCELERATION_GROUNDED_X.ceil
        @velocity_x = [-MAX_SPEED_X, @velocity_x].max
      end
    when :right
      @decelerating = @velocity_x < 0
      if @decelerating
        @velocity_x += DECCELERATION_GROUNDED_X
        @velocity_x = [0, @velocity_x].min
      elsif ((@move_start - state.tick_count) % 5) == 0
        @velocity_x += ACCELERATION_GROUNDED_X.floor
        @velocity_x = [MAX_SPEED_X, @velocity_x].min
      end
    else
      if @decelerating
        if @velocity_x > 0
          @velocity_x = [@velocity_x - DECCELERATION_GROUNDED_X, 0].max
        else
          @velocity_x = [@velocity_x + DECCELERATION_GROUNDED_X, 0].min
        end
      end
    end
  end

  def move_x_airborn
    @decelerating = false
    case move_direction
    when :left
      @velocity_x -= ACCELERATION_AIRBORN_X
      @velocity_x = [-MAX_SPEED_X, @velocity_x].max
    when :right
      @velocity_x += ACCELERATION_AIRBORN_X
      @velocity_x = [MAX_SPEED_X, @velocity_x].min
    end
  end

  def facing_left?
    @velocity_x < 0 || (@velocity_x == 0 && @flip_horizontally)
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
    if @controller == 'keyboard'
      args.inputs.keyboard.key_down.c
    else
      args.inputs.send(@controller).key_down.a
    end
  end

  def move_direction
    @move_start = state.tick_count if inputs.send(@controller).key_down.left_right
    case inputs.send(@controller).left_right
    when -1
      :left
    when 1
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
