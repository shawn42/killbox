define_behavior :pulled_by_black_hole do
  requires :black_hole_coordinator

  setup do
    black_hole_coordinator.register_pullable actor
    reacts_with :remove
  end


  helpers do
    def remove
      black_hole_coordinator.unregister_pullable actor
    end
  end
end
