module KazDev
	# СУБМОДУЛЬ РАСШИРЕНИЯ
	# <<Extension description.>>
	# Этот подмодуль расширения также будет наблюдателем приложения..
	module Cutter
        extend self
        class SelectionSpy <  Sketchup::SelectionObserver
            def onSelectionBulkChange(selection)
                sel_ids = []
                selection.each do |entity|
                    rotation = entity.get_attribute("KazDev", "rotation", false)
                    puts "rotation: #{rotation}"

                    id = [entity.persistent_id]
                    sel_ids.push(id)

                    dict = entity.attribute_dictionary "KazDev"
                    if dict
                        print "Keys: "
                        dict.keys.each {|k| print k + " "}
                        print "\nValues: "
                        dict.values.each {|v| print v.to_s + " "}
                        puts "\n"
                    end
                end
                
                if sel_ids.count > 0
                    puts ("sel_ids: " + sel_ids.to_s)
                    $wd.execute_script("select_markers(#{sel_ids})")
                else
                    $wd.execute_script("select_markers([])")
                end

            end

            def onSelectedCleared(selection)
                $wd.execute_script("select_markers([])")
                puts ("selection sended id: []")
            end
        end

        def show()
            observer = SelectionSpy.new
            selection = Sketchup.active_model.selection
            selection.add_observer(observer)
            $wd = UI::HtmlDialog.new(
            {
            :dialog_title => "Cutter",
            :preferences_key => "com.sample.plugin",
            :scrollable => true,
            :resizable => true,
            :left => 0,
            :top => 0,
            :style => UI::HtmlDialog::STYLE_DIALOG
            })
            
            path = Sketchup.find_support_file "dev/index.html", "Plugins"
            $wd.set_file path
            $wd.show
            $wd.set_size(960, 700)

            $wd.add_action_callback("make_data_list") {|d, arg|
                make_data_list()
            }

            $wd.add_action_callback("setdata") { |d, args|
                id, name, param = args.split(',')
                if param == "true"
                    param = true
                elsif param == "false"
                    param = false
                end
                id = id.to_i
                setdata(id, name, param)
            }

            $wd.set_on_closed { selection.remove_observer(observer) }
            
        end

        def setdata(id, name, param)
            puts "setdata: " + name + " param: " + param.to_s

            if name == "rotation"
                add_param(id, name, param)

                return
            end

            if name == "useit"
                if param == true
                    select_entity(id)
                    puts "useit: true"
                    return
                else
                    unselect_entity(id)
                    puts "useit: false"
                    return
                end
            end
            
            if name == "customer" || "top_thick_grinding" || "left_thick_grinding"
                add_param(id, name, param)
                return
            end

            if name == "bottom_name" || name == "left_name" || name == "top_name" || name == "right_name"
                add_param(id, name, param)
                return
            end
            puts "Ошибка"
        end

        def add_param(id, name, param)
            entities = Sketchup.active_model.active_entities
            found = entities.find {|e| e.persistent_id == id.to_i }
            found.set_attribute('KazDev', name,   param)
            puts "add_param: #{id}, #{name}, #{param}"
        end

        def select_entity(id)
            selection = Sketchup.active_model.selection
            entities = Sketchup.active_model.active_entities
            found = entities.find {|e| e.persistent_id == id.to_i }
            selection.add found
            puts "select_entity: #{id}"
        end

        def unselect_entity(id)
            selection = Sketchup.active_model.selection
            entities = Sketchup.active_model.active_entities
            found = entities.find {|e| e.persistent_id == id.to_i }
            selection.remove found
        end

        def make_data_list()
            selection = Sketchup.active_model.selection
            data = []
            selection.each do |entity|
                if entity.is_a?(Sketchup::Group)
                    list = []
                    list = (get_dimensions(entity))
                    list << (entity.persistent_id)
                    list << (entity.layer.display_name)
                    list << (entity.get_attribute 'KazDev', 'customer', "")
                    list << ((entity.get_attribute 'KazDev', 'allow_rotation') ? "checked" : "unchecked")
                    list << (entity.get_attribute 'KazDev', 'label', "")
                    list << (entity.get_attribute 'KazDev', 'material', "")
                    list << ((entity.get_attribute 'KazDev', 'top_name') ? "checked" : "unchecked")
                    list << ((entity.get_attribute 'KazDev', 'left_name') ? "checked" : "unchecked")
                    list << ((entity.get_attribute 'KazDev', 'bottom_name') ? "checked" : "unchecked")
                    list << ((entity.get_attribute 'KazDev', 'right_name') ? "checked" : "unchecked")
                    list << (entity.get_attribute 'KazDev', 'top_thick_grinding', "")
                    list << (entity.get_attribute 'KazDev', 'left_thick_grinding', "")
                    list << ((entity.get_attribute 'KazDev', 'rotation') ? "checked" : "unchecked")
                    data << list
                end
                # [x y z id layer customer allow_rotation label material top_name left_name bottom_name right_name top_thick left_thick rotation]
                # [0 1 2 3  4     5        6              7     8        9        10        11          12         13        14         15      ]
            end
            data = sort_list(data)
            $wd.execute_script("show_sel_dims(#{data})")
            # puts ("make_data_list= " + data.to_s)
        end

        def sort_list(list)
            list = list.sort_by {|elem| [elem[1], elem[0]]}.reverse
            list = list.sort_by {|elem| [elem[1], elem[0]]}.reverse
            list = list.sort_by {|elem| elem[4]}
            return list
        end


        def get_dimensions(entity)
            model = Sketchup.active_model
            boundingBox = entity.bounds

            dims =  [boundingBox.height,
                     boundingBox.width,
                     boundingBox.depth]

            if dims[0]<dims[1] && dims[0]<dims[2]
                z = dims[0]
                x = dims[2]
                y = dims[1]
                orient = 3
            elsif dims[1]<dims[0] && dims[1]<dims[2]
                z = dims[1]
                x = dims[2]
                y = dims[0]
                orient = 2
            else
                z = dims[2]
                x = dims[1]
                y = dims[0]
                orient = 1
            end

            puts "x_bounds: #{x} y_bounds: #{y} z_bounds: #{z} orient: #{orient}"
        
            faces = entity.entities.grep(Sketchup::Face)
            max_area = 0
            max_face = nil
            right_face = nil
            left_face = nil
            bottom_face = nil
            top_face = nil

            sydes = []
            faces.each do |face|
                if face.area.round == (y * z).round || face.area.round == (x * z).round
                    sydes << face
                end
            end

            case orient
            when 1
                sydes.each do |face|
                    right_face = face if face.normal.x == 1
                    left_face = face if face.normal.x == -1
                    bottom_face = face if face.normal.y == 1
                    top_face = face if face.normal.y == -1
                end
            when 2
                sydes.each do |face|
                    bottom_face = face if face.normal.y == 1
                    top_face = face if face.normal.y == -1
                    right_face = face if face.normal.z == 1
                    left_face = face if face.normal.z == -1
                end
            when 3
                sydes.each do |face|
                    right_face = face if face.normal.x == 1
                    left_face = face if face.normal.x == -1
                    top_face = face if face.normal.z == 1
                    bottom_face = face if face.normal.z == -1
                end
            end

            return [x.to_mm.round(2), y.to_mm.round(2), z.to_mm.round(2)]
        end
        
        def attach_model_spies(model)
			# Прикрепите наблюдателя выбора:
			#
			# Вот где можно было бы присоединить других наблюдателей на уровне модели.
			#
		end

	
		### Методы обратного вызова AppObserver:
		def expectsStartupModelNotifications
			return true
		end
	
		def onNewModel(model)
			attach_model_spies(model)
		end
	
		def onOpenModel(model)
			attach_model_spies(model)
		end

        unless defined?(@loaded)
            UI.menu('Extensions').add_item('cuter') {show()}
            UI.menu('Extensions').add_item('make data list') {make_data_list()}
            @loaded = true
        end
	end
end
