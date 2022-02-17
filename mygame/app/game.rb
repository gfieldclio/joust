require 'app/sprites/player.rb'
require 'app/sprites/platform_tile.rb'

class Game
  attr_gtk

  def tick
    defaults
    render
  end

  def defaults
    state.drag ||= 0.15
    state.gravity ||= -0.4

    if args.state.tick_count == 0
      init_platforms
      init_player
    end
  end

  def init_platforms
    args.state.platforms = []
    args.state.platforms << make_platform(0, 4, num_tiles: 64)
    args.state.platforms << make_platform(0, 14, num_tiles: 15)
    args.state.platforms << make_platform(0, 25, num_tiles: 14)
    args.state.platforms << make_platform(24, 13, num_tiles: 17)
    args.state.platforms << make_platform(22, 24, num_tiles: 20)
    args.state.platforms << make_platform(58, 14, num_tiles: 6)
    args.state.platforms << make_platform(50, 15, num_tiles: 9)
    args.state.platforms << make_platform(58, 25, num_tiles: 6)

    args.state.platforms.each do |platform|
      platform.sprites.each { |platform_sprite| args.outputs.static_sprites << platform_sprite }
    end
  end

  def init_player
    args.state.player = Player.new(args.grid, args.state.platforms.first)
    args.outputs.static_sprites << args.state.player
  end

  def make_platform(x, y, num_tiles:)
    x_pos = x * PlatformTile::TILE_SIZE
    y_pos = y * PlatformTile::TILE_SIZE

    {
      x: x_pos,
      y: y_pos,
      w: x_pos + PlatformTile::TILE_SIZE * num_tiles,
      h: PlatformTile::TILE_SIZE,
      sprites: Array.new(num_tiles) {|i| PlatformTile.new(args.grid, x_pos + (PlatformTile::TILE_SIZE*i), y_pos) }
    }
  end

  def render
    outputs.background_color = [20, 20, 20]
  end
end