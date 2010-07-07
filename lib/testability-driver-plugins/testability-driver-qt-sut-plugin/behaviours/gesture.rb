############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of TDriver. 
## 
## If you have questions regarding the use of this file, please contact 
## Nokia at testabilitydriver@nokia.com . 
## 
## This library is free software; you can redistribute it and/or 
## modify it under the terms of the GNU Lesser General Public 
## License version 2.1 as published by the Free Software Foundation 
## and appearing in the file LICENSE.LGPL included in the packaging 
## of this file. 
## 
############################################################################

module MobyBehaviour

	module QT

		module Gesture

			include MobyBehaviour::QT::Behaviour

			# Flick the screen from the given object (touch the object and cause a flick gesture).
			# Speed and distance of the flick are defined in the tdriver_parameters under the sut used.
			# For custom values see gesture.
			# == params
			# direction::Direction of the flick. Supported direction are: :Up, :Down, :Left, :Right
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid direction or button is given
			# === examples
			#  @object.flick(:Up)   
			def flick( direction, button = :Left, optional_params = {} )

				begin
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen
          
				  speed = calculate_speed(@sut.parameter(:gesture_flick_distance), @sut.parameter(:gesture_flick_speed))
				  distance = @sut.parameter(:gesture_flick_distance).to_i
          params = {:gesture_type => :MouseGesture, :direction => direction, :speed => speed, :distance => distance, :isDrag => false, :button => button, :useTapScreen => use_tap_screen}
          params.merge!(optional_params)

				  do_gesture(params)		
				  do_sleep(speed)
				  
				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed flick with direction \"#{direction}\", button \"#{button.to_s}\".;#{identity};flick;"
					Kernel::raise e        
				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation flick executed successfully with direction \"#{direction}\", button \"#{button.to_s}\".;#{identity};flick;"

				nil
			end

			# Flick the screen from the given object (touch the object and cause a flick gesture)
			# to the given coordinates. Coordinates must be absolute to the screen.
			# Speed and distance of the flick are defined in the tdriver_parameters under the sut used.
			# For custom values see gesture_to.
			# == params
			# x: target x coordinate, must be an absolute screen coordinate  
			# y: target y coordinate, must be an absolute screen coordinate
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button is given
			# === examples
			#  @object.flick_to(150, 120, 1)
			def flick_to( x, y, button = :Left, optional_params = {})

				begin
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen

         

					speed = calculate_speed( @sut.parameter( :gesture_flick_distance ), @sut.parameter( :gesture_flick_speed ) )
				    do_gesture({:gesture_type => :MouseGestureToCoordinates, :x => x, :y => y, :speed => speed, :isDrag => false, :button => button, :useTapScreen => use_tap_screen})		
					do_sleep(speed)

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed flick_to with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};drag;"
					Kernel::raise e        
				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation flick_to executed successfully with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};drag;"

				nil

			end


			# Cause a gesture (flick or drag) for the given object. Nature of the operetion depends on the give parameters.
			# == params
			# direction::Direction of the flick. Supported direction are: :Up, :Down, :Left, :Right
			# speed:: speed of the flick motion in seconds (duration of the motion)
			# distance::distance in pixels of the flick motion
			# optional_params: 
			#   :button: (optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			#   :isDrag: true or false
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid direction or button is given
			# === examples
			#  @object.gesture(:Up, 1, 200)   
			def gesture( direction, speed, distance, optional_params = {:button => :Left, :isDrag => false}) 

				begin
          # change the format for api consitency
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen


					#do_gesture(direction, speed, distance, isDrag, button)
				    params = {:gesture_type => :MouseGesture, :direction => direction, :speed => speed, :distance => distance}
				    params.merge!(optional_params)
				    do_gesture(params)
					do_sleep(speed)

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour", 
					"FAIL;Failed gesture with direction \"#{direction}\", speed \"#{speed.to_s}\", distance \"#{distance.to_s}\".;#{identity};gesture;"
					Kernel::raise e        
				end      

				MobyUtil::Logger.instance.log "behaviour", 
				"PASS;Operation gesture executed successfully with direction \"#{direction}\", speed \"#{speed.to_s}\", distance \"#{distance.to_s}\".;#{identity};gesture;"

				nil
			end

			# Flick/drag the screen from the given object (touch the object and cause a flick or drag gesture)
			# to the given coordinates. Coordinates must be absolute to the screen.
			# == params
			# x: target x coordinate, must be an absolute screen coordinate  
			# y: target y coordinate, must be an absolute screen coordinate
			# speed: speed of the flick. smaller the faster 
			# optional_params: 
			#   :button: (optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			#   :isDrag: true or false
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button is given
			# === examples
			#  @object.gesture_to(150, 120, 1)  
      def gesture_to(x, y, speed, optional_params = {:button => :Left, :isDrag => false})

				begin      
          # change the format for api consitency
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen


          params = {:gesture_type => :MouseGestureToCoordinates, :x => x, :y => y, :speed => speed}
          params.merge!(optional_params)
					do_gesture(params)
					do_sleep(speed) 

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed gesture_to with x \"#{x}\", y \"#{y}\", speed \"#{speed.to_s}\", button \".;#{identity};gesture;"
					Kernel::raise e        
				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation gesture_to executed successfully with x \"#{x}\", y \"#{y}\", speed \"#{speed.to_s}\".;#{identity};gesture;"
				nil
			end

			#see drag_to_object
			def gesture_to_object(target_object, duration, optional_params = {:button => :Left, :isDrag => false})    

				begin
          # change the format for api consitency
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen



          params = {:gesture_type => :MouseGestureTo, :speed => duration}
          params[:targetId] = target_object.id
          params[:targetType] = target_object.attribute('objectType')
          params.merge!(optional_params)
					do_gesture(params)
					do_sleep(duration)

				rescue Exception => e      

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed gesture_to_object with button.;#{identity};drag;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation gesture_to_object executed successfully with button.;#{identity};drag;"

				nil

			end


			# Cause a drag operation on the screen. Basically the same as flick /gesture but done slowly.
			# == params
			# direction::Direction of the drag. Supported direction are: :Up, :Down, :Left, :Right  
			# distance::distance in pixels of the flick motion
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid direction or button is given
			# === examples
			#  @object.drag(:Up, 200) 
			#  @sut.application.GraphWidget.QGraphicsItem(:tooltip => 'node1').drag(:Down, 50) # on elasticnode application - drags item with tooltip 'node1' down 50 pixels
			def drag(direction, distance, button = :Left, optional_params = {})

				begin
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen

					speed = calculate_speed( distance, @sut.parameter( :gesture_drag_speed ) )
          params = {:gesture_type => :MouseGesture, :direction => direction, :speed => speed, :distance => distance, :isDrag => true, :button => button}
          params.merge!(optional_params)
          do_gesture(params)		
					do_sleep( speed )

				rescue Exception => e      
	
					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed drag with direction \"#{direction}\", distance \"#{distance}\", button \"#{button.to_s}\".;#{identity};drag;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation drag executed successfully with direction \"#{direction}\", distance \"#{distance}\", button \"#{button.to_s}\".;#{identity};drag;"

				nil
			end

			# Moves the pointer the given distance to the given direction.
			def move(direction, distance, button = :Left, optional_params = {})

				begin
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen

					speed = calculate_speed( distance, @sut.parameter( :gesture_drag_speed ) )
          params = {:gesture_type => :MouseGesture, :direction => direction, :speed => speed, :distance => distance, :isDrag => false, :button => button, :isMove => true}
          params.merge!(optional_params)
          do_gesture(params)
					do_sleep( speed )

				rescue Exception => e      

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed move with direction \"#{direction}\", distance \"#{distance}\",.;#{identity};move;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation move executed successfully with direction \"#{direction}\", distance \"#{distance}\",.;#{identity};move;"

				nil
			end

			# Cause a drag operation on the screen for an object to a certain point.
			# == params
			# x: target x coordinate, must be an absolute screen coordinate  
			# y: target y coordinate, must be an absolute screen coordinate
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button is given
			# === examples
			#  @object.drag_to(120, 340) 
			#  @sut.application.GraphWidget.QGraphicsItem(:tooltip => 'node1').drag_to(134, 250) # on elasticnode application - drags item with tooltip 'node1' to given coordinates
			def drag_to( x, y, button = :Left, optional_params= {} )

				begin
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen


					distance = distance_to_point(x,y)
					return if distance == 0

					speed = calculate_speed(distance, @sut.parameter(:gesture_drag_speed))
          params = {:gesture_type => :MouseGestureToCoordinates, :x => x, :y => y, :speed => speed, :isDrag => true, :button => button}
          params.merge!(optional_params)
          do_gesture(params)		
					do_sleep( speed )

				rescue Exception => e      

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed drag_to with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};drag;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation drag_to executed successfully with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};drag;"

				nil

			end

			# Cause a drag operation for an object by dragging it to the coordinates of an another object.
			# Object center points are used.
			# == params
			# object::the object that this this object will dragged over.
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button is given
			# === examples
			#  @object.drag_to_object(object2)     
			def drag_to_object(target_object, button = :Left, optional_params = {})       

				begin
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen
          
          

					distance = distance_to_point(target_object.object_center_x, target_object.object_center_y)
					#no drag needed, maybe even attempting to drag to it self
					return if distance == 0

					speed = calculate_speed(distance, @sut.parameter(:gesture_drag_speed))
          params = {:gesture_type => :MouseGestureTo, :speed => speed, :isDrag => true, :button => button}
          params[:targetId] = target_object.id
          params[:targetType] = target_object.attribute('objectType')
          params.merge!(optional_params)
          do_gesture(params)
					do_sleep(speed)


				rescue Exception => e      

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed drag_to_object with button \"#{button.to_s}\".;#{identity};drag;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation drag_to_object executed successfully with button \"#{button.to_s}\".;#{identity};drag;"

				nil

			end

			#utility function for getting the x coordinate of the center of the object
			def object_center_x
				center_x
			end

			#utility function for getting the y coordinate of the center of the object
			def object_center_y
				center_y
			end  


			#Gesture on specific poinst on the screen. Points have to be passed as a array of hashes:
			#[{"x" => 200,"y" => 100, interval => 100},{"x" => 200,"y" => 110, interval => 80}]
			def gesture_points( points, duration, mouse_details = { :press => true, :release => true, :button => :Left, :isDrag => true}, optional_params = {} )

				begin

          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen


					mouse_details[:press] = true  unless mouse_details.has_value?(:press)
					mouse_details[:release] = true  unless mouse_details.has_value?(:release)
					mouse_details[:button] = :Left  unless mouse_details.has_value?(:button)
					mouse_details[:isDrag] = true  unless mouse_details.has_value?(:isDrag)

					raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(mouse_details[:button])

					command = command_params #in qt_behaviour           
					command.command_name('MouseGesturePoints')
					params = {'mouseMove'=>'true'}

					params['button'] = @@_buttons_map[mouse_details[:button]]
					params['press'] = 'false' unless mouse_details[:press]
					params['release'] = 'false' unless mouse_details[:release]
          params['isDrag'] = 'true' if mouse_details[:isDrag]
          params.merge!(optional_params)
          

					millis = duration.to_f
					millis = millis*1000
					speed = millis.to_i
					params['speed'] = speed.to_s
					command.command_params(params)
					point_string = ""
					points.each { |point| point_string << point["x"].to_s << "," << point["y"].to_s << "," << (point["interval"]*1000).to_i.to_s << ";"}
					command.command_value(point_string)

					@sut.execute_command(command)

					do_sleep(duration)

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour", 
					"FAIL;Failed drag_to_object with points \"#{points.to_s}\", duration \"#{duration.to_s}\", mouse_details \"#{mouse_details.to_s}\".;#{identity};gesture_points;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour", 
				"PASS;Operation drag_to_object executed successfully with points \"#{points.to_s}\", duration \"#{duration.to_s}\", mouse_details \"#{mouse_details.to_s}\".;#{identity};gesture_points;"

				nil
			end


		private

			# Performs the actual gesture operation. 
			# Verifies that the parameters are correct and send the command
			# to the sut. 
			# gesture_type: :MouseGesture, :MouseGestureTo, :MouseGestureToCoordinates
			# params = {:direction => :Up, duration => 2, :distance =>100, :isDrag =>false, :isMove =>false }
			def do_gesture(params)
			    validate_gesture_params!(params)

			    if attribute('objectType') == 'Embedded'
				  params['x'] = center_x
				  params['y'] = center_y					
				  params['useCoordinates'] = 'true'
			    end

				command = command_params #in qt_behaviour           
				command.command_name(params[:gesture_type].to_s)
				command.command_params( params )
				@sut.execute_command( command )
			end

			def validate_gesture_params!(params)
			  #direction		
			  if params[:gesture_type] == :MouseGesture
				if params[:direction].kind_of?(Integer)
				  raise ArgumentError.new( "Invalid direction." ) unless 0 <= params[:direction].to_i and params[:direction].to_i <= 360 
				else
				  raise ArgumentError.new( "Invalid direction." ) unless @@_valid_directions.include?(params[:direction])  
				  params[:direction] = @@_direction_map[params[:direction]]
				end
				#distance
				params[:distance] = params[:distance].to_i unless params[:distance].kind_of?(Integer)
				raise ArgumentError.new( "Distance must be an integer and greater than zero." ) unless  params[:distance] > 0
			  elsif params[:gesture_type] == :MouseGestureToCoordinates
				raise ArgumentError.new("X and Y must be integers.") unless params[:x].kind_of?(Integer) and params[:y].kind_of?(Integer)
			  elsif params[:gesture_type] == :MouseGestureTo
				raise ArgumentError.new("targetId and targetType must be defined.") unless params[:targetId] and params[:targetType]
			  end			  

			  #duration/speed 
			  params[:speed] = params[:speed].to_f unless params[:speed].kind_of?(Numeric)
			  raise ArgumentError.new( "Duration must be a number and greated than zero, was:" + params[:speed].to_s) unless params[:speed] > 0
			  duration_secs = params[:speed].to_f
			  duration_secs = duration_secs*1000
			  params[:speed] = duration_secs.to_i

			  #mouseMove true always
			  params[:mouseMove] = true

			  params[:button] = :Left unless params[:button]
			  raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(params[:button])
			  params[:button] = @@_buttons_map[params[:button]]

			  if params[:isMove] == true
				params[:press] = 'false'
				params[:release] = 'false'
			  end

			end


			def do_sleep(time)

			  if MobyUtil::Parameter[ @sut.id ][ :sleep_disabled, nil ] != 'true'
				time = time.to_f
				time = time * 1.3
				#for flicks the duration of the gesture is short but animation (scroll etc..) may not
				#so wait at least one second
				time = 1 if time < 1	
				sleep time
			  end

			end

			def calculate_speed(distance, speed)

				distance = distance.to_f
				speed = speed.to_f
				duration = distance/speed
				duration

			end

			def distance_to_point(x, y)

				x = x.to_i
				y = y.to_i
				dist_x = x - center_x.to_i
				dist_y = y - center_y.to_i

				return 0 if dist_y == 0 and dist_x == 0     
				distance = Math.hypot( dist_x, dist_y )
				distance

			end

			# enable hooking for performance measurement & debug logging
			MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

		end

	end
end
