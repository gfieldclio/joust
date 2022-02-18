require 'app/sprites/player.rb'
require 'app/sprites/platform_tile.rb'

class Game
  attr_gtk

  GRAVITY = -0.2

  def tick
    defaults
    render
    add_players
  end

  def defaults
    if state.tick_count == 0
      init_platforms
      state.players = []
    end
  end

  def init_platforms
    state.platforms = []
    state.platforms << make_platform(0, 4, num_tiles: 64, spawn_point: 30)
    state.platforms << make_platform(0, 14, num_tiles: 15, spawn_point: 8)
    state.platforms << make_platform(0, 25, num_tiles: 14)
    state.platforms << make_platform(24, 13, num_tiles: 17)
    state.platforms << make_platform(22, 24, num_tiles: 20, spawn_point: 7)
    state.platforms << make_platform(58, 14, num_tiles: 6)
    state.platforms << make_platform(50, 15, num_tiles: 9, spawn_point: 5)
    state.platforms << make_platform(58, 25, num_tiles: 6)

    state.platforms.each do |platform|
      platform.sprites.each { |platform_sprite| outputs.static_sprites << platform_sprite }
    end
  end

  def add_players
    add_player('keyboard') if inputs.keyboard.key_down.c && state.players.none? {|player| player.controller == 'keyboard'}
    add_player('controller_one') if inputs.controller_one.key_down.a && state.players.none? {|player| player.controller == 'controller_one'}
    add_player('controller_two') if inputs.controller_two.key_down.a && state.players.none? {|player| player.controller == 'controller_two'}
  end

  def add_player(controller)
    player = Player.new(args, controller)
    state.players << player
    outputs.static_sprites << player
  end

  def make_platform(x, y, num_tiles:, spawn_point: nil)
    x_pos = x * PlatformTile::TILE_SIZE
    y_pos = y * PlatformTile::TILE_SIZE
    spawn_point_range = []
    spawn_point_range = (spawn_point - 2..spawn_point + 2).to_a if !spawn_point.nil?

    state.new_entity(
      :platform,
      rect: [x_pos, y_pos, PlatformTile::TILE_SIZE * num_tiles, PlatformTile::TILE_SIZE].rect.to_hash,
      spawn_point: nil
    ) do |platform|
      if !spawn_point.nil?
        platform.spawn_point = [
          x_pos + (spawn_point * PlatformTile::TILE_SIZE) + (0.5 * PlatformTile::TILE_SIZE),
          y_pos + PlatformTile::TILE_SIZE
        ].point.to_hash
      end

      platform.sprites = Array.new(num_tiles) do |i|
        path = PlatformTile::WALL_MIDDLE_PATH
        path = PlatformTile::WALL_LEFT_PATH if i == 0
        path = PlatformTile::WALL_RIGHT_PATH if i == (num_tiles - 1)
        path = PlatformTile::WALL_LEFT_PATH if i == spawn_point_range.first
        path = PlatformTile::WALL_RIGHT_PATH if i == spawn_point_range.last

        PlatformTile.new(args.grid, x_pos + (PlatformTile::TILE_SIZE*i), y_pos, path, spawn_point_range.include?(i))
      end
    end
  end

  def render
    outputs.background_color = [20, 20, 20]
    state.players.each(&:move)
  end
end