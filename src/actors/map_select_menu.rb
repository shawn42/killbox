define_actor :map_select_menu do
  behavior do
    requires :input_manager, :stage
    setup do
      map_files = Dir[Gamebox.configuration.data_path+'/maps/*.tmx']

      icon_x = 350
      icon_y = 400
      map_count = 0
      map_files.each do |map_file|
        map = File.basename(map_file, ".tmx")
        if File.exists?("#{Gamebox.configuration.gfx_path}map/#{map}_thumb.png")
          stage.create_actor(:icon, image: "map/#{map}_thumb.png", x: icon_x, y: icon_y)
          stage.create_actor(:label, text: map_count+1, x: icon_x-150, y: icon_y-200, font_name: "vigilanc.ttf" , font_size: 100, color: [244, 215, 227])
          input_manager.reg :down, Object.const_get("Kb#{map_count+1}") do actor.emit :start, map.to_sym end


          if map_count.odd?
            icon_y += 500 
            icon_x = 100
          else
            icon_x += 500
          end
          map_count += 1
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
