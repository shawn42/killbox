require 'spec_helper'


describe "Foxy bombing", acceptance: true do
  let(:zones) { FoxyAcceptanceHelpers.get_test_map("shooting").object_groups["zones"].inject({}) do |h,x| h[x[:name]] = x; h; end }
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
      rotation: 0.ish,
      on_ground: true
    see_bottom_right_standing_above floor_zone[:y]
    see_bottom_left_standing_above floor_zone[:y]
  end

  it 'can place and arm a land mine' do
    place_land_mine

    game.actors(:bomb).should be_empty

    see_actor_attrs :land_mine,
      armed: false,
      x: foxy.x.ish,
      y: floor_zone[:y].ish

    # warp to safety
    foxy.x += 300

    # wait for land mine to arm
    update 1000, step: 20

    see_actor_attrs :land_mine,
      armed: true
  end


end

