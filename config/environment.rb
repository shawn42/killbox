APP_ROOT = "#{File.join(File.dirname(__FILE__),"..")}/"

require 'gamebox'

Gamebox.configure do |config|
  config.config_path = APP_ROOT + "config/"
  config.data_path = APP_ROOT + "data/"
  config.music_path = APP_ROOT + "data/music/"
  config.sound_path = APP_ROOT + "data/sounds/"
  config.gfx_path = APP_ROOT + "data/graphics/"
  config.fonts_path = APP_ROOT + "data/fonts/"

  config.gb_config_path = GAMEBOX_PATH + "config/"
  config.gb_data_path = GAMEBOX_PATH + "data/"
  config.gb_music_path = GAMEBOX_PATH + "data/music/"
  config.gb_sound_path = GAMEBOX_PATH + "data/sounds/"
  config.gb_gfx_path = GAMEBOX_PATH + "data/graphics/"
  config.gb_fonts_path = GAMEBOX_PATH + "data/fonts/"
  
  config.stages = [:player_select, :level_play, :score]
  # config.stages = [:main_menu, :level_play, :score]
  config.game_name = "Foxy"
end

[GAMEBOX_PATH, APP_ROOT, File.join(APP_ROOT,'src')].each{|path| $: << path }
require "gamebox_application"

require_all Dir.glob("src/*.rb").reject{ |f| f.match("src/app.rb") }
directory_load_order = %w(behaviors actors)
directory_load_order.each do |dir|
  require_all Dir.glob("src/#{dir}/**/*.rb")
end
# require_all Dir.glob("**/*.rb").reject{ |f| f.match("spec/") || f.match("src/app.rb")}
Gosu::enable_undocumented_retrofication


