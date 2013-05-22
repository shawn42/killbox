define_actor :map_select_menu do
  behavior do
    requires :input_manager, :stage
    setup do
      map_files = Dir[Gamebox.configuration.data_path+'/maps/*.tmx']

      icon_width = 250
      icon_height = 250
      
      # start here
      left_x = 250
      icon_x = left_x
      icon_y = icon_height

      map_count = 0
      map_files.each do |map_file|
        map = File.basename(map_file, ".tmx")
        if File.exists?("#{Gamebox.configuration.gfx_path}map/#{map}_thumb.png")
          stage.create_actor(:icon, image: "map/#{map}_thumb.png", x: icon_x, y: icon_y)
          stage.create_actor(:label, text: map_count+1, x: icon_x-icon_width / 2+50, y: icon_y-icon_height/2, font_name: "vigilanc.ttf" , font_size: (icon_height/2), color: [244, 215, 227])
          input_manager.reg :down, Object.const_get("Kb#{map_count+1}") do actor.emit :start, map.to_sym end

          map_count += 1
          if map_count % 4 == 0
            icon_y += icon_height
            icon_x = left_x
          else
            icon_x += icon_width
          end
        end
      end

      reacts_with :remove
    end

    helpers do
      def remove
        input_manager.unsubscribe_all self
      end
    end


  end

end
