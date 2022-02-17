require 'app/game.rb'

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick

  args.outputs.primitives << args.gtk.current_framerate_primitives
end
