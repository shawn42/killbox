define_behavior :selectable do
  setup do
    actor.has_attributes selected: false, active: false
    reacts_with :select, :deselect, :activate, :deactivate
  end

  helpers do
    def select
      actor.selected = true
      actor.emit :selected
    end
    def deselect
      actor.selected = false
      actor.emit :deselected
    end
    def activate
      actor.active = true
      actor.emit :activated
    end
    def deactivate
      actor.active = false
      actor.emit :deactivated
    end
  end
end
