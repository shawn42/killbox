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
          # TODO calculate a vel to use here
          distance = (vec2(target.x, target.y) - vec2(sword.x, sword.y)).magnitude
          if distance < sword.slice_reach
            target.react_to :sliced, sword
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
