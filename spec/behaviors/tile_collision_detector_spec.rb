require 'spec_helper'

describe :tile_collision_detector do
  # TODO AAAAAHHHHH gamebox should hide this from me! VVVVVVVVVV
  let(:opts) { {} } 
  subject { subcontext[:behavior_factory].add_behavior actor, :tile_collision_detector, opts }
  let(:director) { evented_stub(stub_everything('director')) }
  let(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    it[:director] = director
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor, :behavior, :this_object_context])
    _mocks.each do |k,v|
      it[k] = v
    end
    it
  end
  let!(:actor) { subcontext[:actor] }
  # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  let(:tile_size) { 16 }
  let(:map_data) { stub('map data', tile_size: tile_size, tile_grid: grid) }
  let(:grid) { [
    [nil, 1 ,nil],
    [nil,nil,nil],
    [nil,nil, 1 ],
  ]}
  let(:map) { stub('map', map_data: map_data) }

  describe "a single point object" do
    before do
      actor.has_attributes vel: vec2(0,0), 
                           bb: Rect.new(0,0,10,10), 
                           map: map,
                           position: vec2(5,5),
                           rotation: 0,
                           width: 10,
                           height: 10,
                           collision_point_deltas: [vec2(0,0)]

    end

    it 'emits w/ empty data when there are no collisions' do
      subject
      
      expects_event actor, :tile_collisions, [[nil]] do
        director.fire :update, 1
      end
    end

    it 'emits w/ data when there is a basic left collision' do
      actor.position = vec2(12, actor.position.y)
      actor.vel = vec2(5,0)
      subject
      
      expects_event actor, :tile_collisions, [[[{row: 0, col: 1, tile_face: :left, hit: [16.ish, 5.0.ish, 17.0.ish, 5.0.ish], point_index: 0, tile_bb: tile_bb_for(1,0)}]]] do
        director.fire :update, 1
      end
    end

    it 'emits w/ data when with collision on the corner' do
      actor.position = vec2(30, 30)
      actor.bb = Rect.new(25,25,35,35)
      actor.vel = vec2(4.1,4.1)
      subject
      
      expects_event actor, :tile_collisions, [[[{row: 2, col: 2, tile_face: :top, 
        hit: [32, 32, 34.1, 34.1].ish, point_index: 0, tile_bb: tile_bb_for(2,2)}]]] do
        director.fire :update, 1
      end
    end
  end

  describe "a player-like object at glancing angle" do
    let(:grid) { [[nil,nil, 1]] * 8 }
    before do
      actor.has_attributes vel: vec2(0,-4), 
                           bb: Rect.new(0,0,16*3,16*8), 
                           map: map,
                           position: vec2(17, 65),
                           rotation: 0.0,
                           rotation_vel: -3,
                           width: 28,
                           height: 40,
                           collision_point_deltas: [
                             vec2(-14.0, -20.0), 
                             vec2(14.0, -20.0), 
                             vec2(14.0, -10.0), 
                             vec2(14.0, 10.0), 
                             vec2(14.0, 20.0), 
                             vec2(-14.0, 20.0), 
                             vec2(-14.0, 10.0), 
                             vec2(-14.0, -10.0)]
    end

    it 'does not get stuck on a wall' do
      subject
      
      expects_event actor, :tile_collisions, [[[{row: 5, col: 2, tile_face: :left, hit: 
        [32, 80.367, 32.027, 80.239].ish, point_index: 4, tile_bb: tile_bb_for(2, 5)}]]] do
      director.fire :update, 1
      end
    end
  end

  def tile_bb_for(col, row)
    [col*tile_size, row*tile_size, tile_size, tile_size].ish
  end


end
