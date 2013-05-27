require 'spec_helper'


describe "Foxy shooting", acceptance: true do
  let(:zones) { FoxyAcceptanceHelpers.get_test_map("shooting").object_groups.detect{|og|og.name == "zones"}.objects.inject({}) do |h,x| h[x.name] = x; h; end }
  let(:floor_zone) { zones["floor"] }
  let(:right_wall_zone) { zones["right_wall"] }

  let(:tile_size) { 36 }
  let(:map) { game.actor(:map) }
  let(:foxy) { game.actor(:foxy) }

  let(:foxy_w) { 32 }
  let(:foxy_h) { 60 }

  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    mock_image 'boxy.png' # TODO: provide width and height as 2nd and third args
    mock_image 'bullet.png'
    mock_image 'bomb.png'

    configure_game_with_testing_stage  map_name: "shooting", player_count: 2

    # See foxy land standing where expected:
    update 2000, step: 20
    see_actor_attrs :foxy, 
      x: 504.ish, # as placed in shooting.tmx
      rotation: 0.ish
    see_bottom_right_standing_above floor_zone.y
    see_bottom_left_standing_above floor_zone.y
  end

  it 'can shoot another player' do
    foxies = game.actors(:foxy)
    foxies.size.should == 2

    foxy1 = foxies[0]
    foxy2 = foxies[1]

    foxy1.y = foxy2.y

    look_right
    shoot
    update 1000, step: 20

    foxy2.should_not be_alive
    game.actors(:foxy).size.should == 1
  end

  it 'does not snap strangle when shield wears off' do
    # TODO setup movement spec to use a new map
    # then move this spec back
    max_x = foxy.x
    foxy.when :x_changed do
      max_x = foxy.x if foxy.x > max_x
    end

    # get going
    press_key KbD
    update 1000, step: 20

    shields_up
    update 20
    release_key KbD
    # should keep floating right
    # what for shields to wear off
    update 1300, step: 20

    see_bottom_right_standing_above floor_zone.y
    see_bottom_left_standing_above floor_zone.y
    foxy.x.should >= max_x
  end


  it 'shoots to the right' do
    see_actor_attrs :foxy, gun_direction: vec2(1,0) # gun pointing right

    shoot

    bullet = game.actor(:bullet)

    bullet.should be # bullet exists
    bullet.x.should > foxy.x # bullet is to the right of foxy about middle-high and traveling right
    last_bullet_x = bullet.x
    bullet.y.should == foxy.y.ish
    bullet.vel.angle.should == 0.ish
    bullet.vel.magnitude.should > 1 # don't want to be assertive about exact speed, just that it's going

    # after a half second, the bullet is further to the right at precisely same height
    update 250, step: 20
    bullet.should be_alive
    bullet.x.should > last_bullet_x
    bullet.y.should == foxy.y.ish

    # the bullet should hit the far-right wall and disappear
    ticks = 0 # safety catch on test
    while bullet.alive? && ticks < 1000
      update 20
      ticks += 1
    end
    bullet.should_not be_alive
    bullet.x.should == right_wall_zone.x.ish(15)
  end

  it 'shoots at the correct angle when floating/spinning' do
    # Jump and begin tumbling counter-clockwise, pausing at -15 degrees:
    jump 1000
    ticks = 0 # prevent infinite loop
    while foxy.rotation > -15 && ticks < 250
      update 20
      ticks += 1
    end
    foxy.rotation.should <= -15

    # Now fire
    shoot
    
    bullet = game.actor(:bullet)
    bullet.should be # bullet exists

    bullet_start_x = bullet.x
    bullet_start_y = bullet.y

    # See the bullet trajectory matches foxy's rotation:
    radians_to_degrees(bullet.vel.angle).should == -15.ish

    # sanity-check vector alignment: should be a straight line from foxy's center, through the gun tip, to the bullet.
    # (Ie, the vector angles need to be the same)
    foxy_vector             = body_vector(foxy)
    original_gun_tip_vector = body_vector(foxy.gun_tip)
    bullet_vector           = body_vector(bullet)
    foxy_to_bullet          = bullet_vector - foxy_vector
    foxy_to_gun_tip         = original_gun_tip_vector - foxy_vector
    gun_tip_to_bullet       = bullet_vector - original_gun_tip_vector

    foxy_to_gun_tip.angle.should == foxy_to_bullet.angle.ish

    # See the rotation stays correct over time:
    update 100, step: 20
    radians_to_degrees(bullet.vel.angle).should == -15.ish
    bullet.x.should > bullet_vector.x # bullet should have moved right
    bullet.y.should < bullet_vector.y # bullet should have moved up

    # See that a vector from the original gun tip to the new bullet matches the angle of the original gun_tip_to_bullet
    new_bullet_vector = body_vector(bullet)
    original_gun_tip_to_new_bullet_vector = new_bullet_vector - original_gun_tip_vector
    original_gun_tip_to_new_bullet_vector.angle.should == gun_tip_to_bullet.angle.ish
  end

end

