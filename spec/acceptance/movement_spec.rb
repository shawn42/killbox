require 'spec_helper'


describe "Foxy movement", acceptance: true do
  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    mock_image 'boxy.png'
    mock_image 'bullet.png'
    mock_image 'bomb.png'

    configure_game_with_testing_stage map_name: "basic_jump", tile_size: 16
  end

  let(:floor_y) { 146 }
  let(:foxy_h) { 60 }
  let(:foxy_w) { 32 }

  let(:tile_size) { 16 }
  let(:map) { game.actor(:map) }
  let(:foxy) { game.actor(:foxy) }

  it 'does not super jump in the wrong direction' do
    foxy.x = 40
    update 3000, step: 20
    see_actor_attrs :foxy, 
      x: 40.ish,
      y: floor_y.ish,
      rotation: 0.ish

    press_key KbD # right
    update 10
    press_key KbN # start charge jump
    update 1000, step: 20

    release_key KbN
    update 10
    release_key KbD

    update 1000, step: 20


    foxy.vel.angle.should == 0.ish
  end

  it 'walks over gaps in the floor (does not switch planes)' do
    foxy.x = 40

    update 3000, step: 20

    see_actor_attrs :foxy, 
      x: 40.ish,
      y: floor_y.ish,
      rotation: 0.ish

    count = 0
    while foxy.on_ground? && count < 1000
      # there's a hole 7 tiles from the left
      break unless foxy.on_ground
      count += 1
      walk_right 10
    end
    count.should < 1000

    update 2000, step: 10

    see_actor_attrs :foxy, 
      y: floor_y.ish,
      rotation: 0.ish

    foxy.x.should > 120
  end

  it 'jumps from floor to ceiling and back' do
    foxy.x = 100

    see_actor_attrs :foxy, 
      x: 100.ish

    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: 100.ish,
      y: floor_y.ish,
      rotation: 0.ish

    jump 3000
    update 2000, step: 20

    see_actor_attrs :foxy, 
      x: 100.ish,
      y: (tile_size + foxy_h / 2.0).ish,
      rotation: 180.ish

    jump 3000
    update 2000, step: 20

    see_actor_attrs :foxy, 
      x: 100.ish,
      y: floor_y.ish,
      rotation: 0.ish
  end

  it 'does not shoot self into floor' do
    # settle
    update 2000, step: 20

    look_up
    shoot

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: floor_y.ish,
      rotation: 0.ish

  end

  it 'walks and rotates to wall' do
    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: floor_y.ish

    walk_left 1200

    see_actor_attrs :foxy, 
      on_ground: true,
      rotation: 90.ish,
      x: 46.ish

    foxy.y.should < floor_y

  end

  it 'grabs the wall when we rotate next to it' do
    start_x = tile_size + foxy_w / 2 + 1
    foxy.x = start_x

    see_actor_attrs :foxy, 
      x: start_x.ish

    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: start_x.ish,
      y: floor_y.ish,
      rotation: 0.ish

    jump 100
    update 1000, step: 20

    see_actor_attrs :foxy, 
      rotation: 90.ish,
      rotation_vel: 0.ish

  end

  context "shields up" do
    it 'does not get stuck when glancing off the wall' do
      start_x = tile_size + foxy_w / 2 + 1
      foxy.x = start_x

      see_actor_attrs :foxy, 
        x: start_x.ish

      # settle
      update 4000, step: 20

      see_actor_attrs :foxy, 
        x: start_x.ish,
        y: floor_y.ish,
        rotation: 0.ish

      jump 10
      update 20

      shields_up

      # wait for shields to wear off
      update 3000, step: 20

      # should now stick to the ceiling
      see_actor_attrs :foxy, 
        rotation: 180.ish,
        rotation_vel: 0.ish

      # bounced off the wall
      foxy.x.should > start_x

    end
  end

  context "bombs" do
    it 'does not blast you through the floor' do
      update 4000, step: 20

      see_actor_attrs :foxy, 
        x: 120.ish,
        y: floor_y.ish,
        rotation: 0.ish

      look_up
      10.times do
        charge_and_throw_bomb 50
        update 1
      end
      update 2500, step: 20
      shields_up

      update 1200, step: 20

      see_actor_attrs :foxy, 
        x: 120.ish,
        rotation: 0.ish

      foxy.y.should be < floor_y

    end
  end

end

