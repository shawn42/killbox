require 'spec_helper'

class MockImage
  def width; 28; end
  def height; 40; end
end

class FakeLevel
  attr_accessor :named_objects
  def initialize
    @named_objects = {}
  end
end

class JumpAcceptanceStage < LevelPlayStage
  include TestStageHelpers
  # construct_with *Stage.object_definition.component_names

  def setup
    clear_drawables
    director.update_slots = [:first, :before, :update, :last]

    require 'tmx'
    map = Tmx::Map.new("#{APP_ROOT}/spec/fixtures/maps/basic_jump.tmx")

    map_data = LevelLoader::MapData.new
    map_data.tile_grid = LevelLoader.generate_map(map)[0]

    map_data.tileset_image = "map/tileset.png"
    # all tiles will be square!
    map_data.tile_size = 16
    
    map_actor = create_actor :map, map_data: map_data

    @level = FakeLevel.new
    @level.named_objects[:player1] = create_actor :foxy, map: map_actor, x: 120, y: 60

    setup_players
  end

end

describe "Foxy jumping", acceptance: true do
  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    # mock_tiles 'foxy.png', 84/3, 360/9
    mock_image 'foxy.png'
    mock_image 'bullet.png'
    mock_image 'bomb.png'
    Gamebox.configuration.stages = [:jump_acceptance]

    game
  end

  let(:tile_size) { 16 }
  let(:map) { game.actor(:map) }
  let(:foxy) { game.actor(:foxy) }

  it 'jumps from floor to ceiling and back' do
    see_actor_attrs :foxy, 
      x: 120.ish

    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: 155.ish,
      rotation: 0.ish

    jump 2000
    update 1000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: (tile_size + foxy.height / 2.0 + 1).ish,
      rotation: 180.ish

    jump 2000
    update 2000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: 155.ish,
      rotation: 0.ish
  end

  it 'does not shoot self into floor' do
    # settle
    update 2000, step: 20

    press_key KbUp
    press_key KbB

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: 155.ish,
      rotation: 0.ish

  end

  it 'walks and rotates to wall' do
    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: 155.ish

    press_key KbA
    update 1000, step: 20
    release_key KbA

    see_actor_attrs :foxy, 
      on_ground: true,
      rotation: 90.ish,
      x: 37.ish

    foxy.y.should < 155

  end

  it 'grabs the wall when we rotate next to it' do
    foxy.x = 31

    see_actor_attrs :foxy, 
      x: 31.ish

    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: 31.ish,
      y: 155.ish,
      rotation: 0.ish

    jump 100
    update 1000, step: 20

    see_actor_attrs :foxy, 
      rotation: 90.ish,
      rotation_vel: 0.ish

  end

  context "shields up" do
    it 'grabs the wall when we rotate next to it' do
      foxy.x = 31

      see_actor_attrs :foxy, 
        x: 31.ish

      # settle
      update 4000, step: 20

      see_actor_attrs :foxy, 
        x: 31.ish,
        y: 155.ish,
        rotation: 0.ish

      jump 10

      update 20

      shields_up

      update 3000, step: 20

      see_actor_attrs :foxy, 
        rotation: 90.ish,
        rotation_vel: 0.ish

    end
  end

  context "bombs" do
    it 'does not blast you through the floor' do
      update 4000, step: 20

      see_actor_attrs :foxy, 
        x: 120.ish,
        y: 155.ish,
        rotation: 0.ish

      look_up
      10.times do
        bomb 50
        update 1
      end
      update 2500, step: 20
      shields_up

      update 1200, step: 20

      see_actor_attrs :foxy, 
        x: 120.ish,
        y: 155.ish,
        rotation: 0.ish

    end
  end

  def jump(amount)
    # charge & jump
    press_key KbN
    update amount, step: 20
    release_key KbN
  end

  def bomb(amount)
    # charge & throw
    press_key KbM
    update amount, step: 20
    release_key KbM
  end

  def look_up
    press_key KbW
  end

  def shields_up
    press_key KbV
  end

end

