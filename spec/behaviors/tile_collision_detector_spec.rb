require 'spec_helper'

describe :tile_collision_detector do
  # TODO AAAAAHHHHH gamebox should hide this from me! VVVVVVVVVV
  let(:opts) { {} }
  subject { subcontext[:behavior_factory].add_behavior actor, :tile_collision_detector, opts }
  let(:director) { evented_stub(stub_everything('director')) }
  let(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor, :behavior, :this_object_context])
    _mocks.each do |k,v|
      it[k] = v
      it[:director] = director
    end
    it
  end
  let!(:actor) { subcontext[:actor] }
  # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  let(:map_data) { stub('map data', tile_size: 16, tile_grid: grid) }
  let(:grid) { [
    [nil, 1 ,nil],
    [nil,nil,nil],
    [nil,nil,nil],
  ]}
  let(:map) { stub('map', map_data: map_data) }

  describe "a valid actor" do
    before do
      actor.has_attributes vel: vec2(0,0), 
                           bb: Rect.new(0,0,10,10), 
                           map: map,
                           x: 5,
                           y: 5,
                           rotation: 0,
                           width: 10,
                           height: 10,
                           collision_point_deltas: [vec2(0,0)]

    end

    it 'emits w/ empty data when there are no collisions' do
      subject
      
      expects_event actor, :tile_collisions, [[nil]] do
        director.fire :update, 61
      end
    end

    it 'emits w/ data when there is a collision' do
      actor.x = 12
      actor.vel = vec2(5,0)
      subject
      
      expects_event actor, :tile_collisions, [[[{:row=>0, :col=>1, :tile_face=>:left, :hit=>[16.ish, 5.0.ish, 17.0.ish, 5.0.ish], :point_index=>0}]]] do
        director.fire :update, 61
      end
    end
  end
end
