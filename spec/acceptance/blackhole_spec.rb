require 'spec_helper'


describe "Blackhole interaction", acceptance: true do

  # TODO eeewwww
  let(:zones) { FoxyAcceptanceHelpers.get_test_map("blackhole").object_groups.detect{|og|og.name == "zones"}.objects.inject({}) do |h,x| h[x.name] = x; h; end }
  let(:jump_target_zone) { zones["jump_target"] }
  let(:start_zone) { zones["start_zone"] }

  let(:tile_size) { 36 }
  let(:foxy_w) { 32 }
  let(:foxy_h) { 60 }

  let(:map) { game.actor(:map) }
  let(:foxy) { game.actor(:foxy) }
  let(:black_hole) { game.actor(:black_hole) }

  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    mock_image 'blackhole.png'

    configure_game_with_testing_stage map_name: "blackhole"

    # See foxy land standing where expected:
    update 200, step: 20
    see_actor_attrs :foxy, 
      rotation: 0.ish,
      on_ground: true

    see_foxy_within_zone start_zone
    black_hole.should be
  end

  it 'moves player in non-linear path' do
    max_jump 

    update 4_000, step: 20

    see_actor_attrs :foxy, 
      rotation: 180.ish,
      on_ground: true

    see_foxy_within_zone jump_target_zone
  end
end
