class SwordCoordinator

  attr_accessor :active_swords, :slice_listeners
  def initialize
    @active_swords = []
    @slice_listeners = Hash.new { 0 }
  end

  def register_sword(sword)
    @active_swords << sword
    sword.when :slice do
      unregister_sword sword
      @slice_listeners.keys.each do |target|

        if target != sword
          sword_loc = vec2(sword.x, sword.y)
          slice_vector = vec2(target.x, target.y) - sword_loc 
          distance = slice_vector.magnitude
          look_vector = sword.gun_tip - sword_loc
          arc_angle = slice_vector.angle_deg_with look_vector

          if distance < sword.slice_reach && arc_angle < 45
            target.react_to :sliced, sword, arc_angle
          end
        end
      end
    end
  end

  def register_sliceable(sliceable)
    @slice_listeners[sliceable] += 1
  end

  def unregister_sliceable(sliceable)
    @slice_listeners[sliceable] -= 1
    @slice_listeners.delete sliceable if @slice_listeners[sliceable] == 0
  end

  def unregister_sword(sword)
    @active_swords.delete sword
  end

end
