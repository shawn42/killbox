define_actor :device_detector do
  has_behaviors do
    selectable
  end

  behavior do
    setup do
      actor.has_attributes path: nil, input_id: nil
    end

    helpers do
      def react_to(name, *args)
        # KbRangeBegin # KbRangeEnd # MsRangeBegin # MsRangeEnd # GpRangeBegin # GpRangeEnd 
        id = BUTTON_SYM_TO_ID[name]

        if keyboard?(id) || gamepad?(id)
          log "device_detector picked up: #{name}"
          actor.input_id = id
          actor.emit :path_value_changed, actor.path, actor.input_id
          actor.emit :done
        end
      end

      def keyboard?(id)
        (KbRangeBegin..KbRangeEnd).include?(id)
      end

      def gamepad?(id)
        (GpRangeBegin..GpRangeEnd).include?(id)
      end
    end
      
  end
end
