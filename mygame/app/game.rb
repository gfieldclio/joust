require 'app/sprites/player.rb'

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
      args.state.player = Player.new(args.grid)
      args.outputs.static_sprites << args.state.player
    end
  end

  def render
    outputs.background_color = [20, 20, 20]
  end
end