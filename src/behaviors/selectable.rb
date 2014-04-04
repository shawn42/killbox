define_behavior :selectable do
  setup do
    actor.has_attributes selected: false, active: false
    reacts_with :select, :deselect, :activate, :deactivate
  end

  helpers do
    def select
      actor.selected = true
    end
    def deselect
      actor.selected = false
    end
    def activate
      actor.active = true
    end
    def deactivate
      actor.active = false
    end
  end
end
