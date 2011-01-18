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

    # == description
    # Gesture behaviour methods are used to do different gestures with UI objects. Various methods exist for different speeds, targets and other options.
    #    
    # == behaviour
    # QtGesture
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # *
    #
    # == sut_type
    # QT
    #
    # == sut_version
    # *
    #
    # == objects
    # *
    #
	  module Gesture

	    include MobyBehaviour::QT::Behaviour

	    # == description
      # Flick the screen at the location of the object (touch the object and do a flick gesture).
      # Speed and distance of the flick are defined in the tdriver_parameters under the sut used.
      # By default a flick is a fast gesture.
      # For custom values see the gesture method.
      #
      # == arguments
      # direction
      #  Symbol
      #   description: Direction of the flick. Please see [link="#directions_table"]the directions table[/link] for valid direction symbols.  
      #   example: :Left
      #  Integer
      #   description: Direction of the flick as degrees with 0 being up and 90 right.
      #   example: 270
      #
      # button
      #  Symbol
      #   description: The mouse button pressed while the drag is executed can be defined. Please see [link="#buttons_table"]the buttons table[/link] for valid button symbols.
      #   example: :Middle
      #   default: :Left
      #
      # optional_params
      #  Hash
      #   description: The only optional argument supported by flick is :use_tap_screen.
      #   example: { :use_tap_screen => 'true' }
      #   default: { :use_tap_screen => 'false' }  
      #
      # == returns
      # NilClass
      #   description: Always returns nil
      #   example: nil
      #
      # == exceptions
      # ArgumentError
      #   description: One of the arguments is not valid  
	    def flick( direction, button = :Left, optional_params = {} )

		  begin
            use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
              optional_params[:use_tap_screen].to_s
            optional_params[:useTapScreen] = use_tap_screen
            
		    speed = calculate_speed(@sut.parameter[:gesture_flick_distance], @sut.parameter[:gesture_flick_speed])
		    distance = @sut.parameter[:gesture_flick_distance].to_i
            params = {:gesture_type => :MouseGesture, :direction => direction, :speed => speed, :distance => distance, :isDrag => false, :button => button, :useTapScreen => use_tap_screen}
            params.merge!(optional_params)

		    do_gesture(params)		
		    do_sleep(speed)
		    
		  rescue Exception => e

		    $logger.log "behaviour" , "FAIL;Failed flick with direction \"#{direction}\", button \"#{button.to_s}\".;#{identity};flick;"
		    Kernel::raise e        
		  end      

		  $logger.log "behaviour" , "PASS;Operation flick executed successfully with direction \"#{direction}\", button \"#{button.to_s}\".;#{identity};flick;"

		  nil
	    end

	    # == description
      # Flick the screen at the location of the object (touch the object and do a flick gesture), ending the flick at the specified coordinates.
      # Speed and distance of the flick are defined in the tdriver_parameters under the sut used.
      # By default a flick is a fast gesture.
      # For custom values see the gesture_to method.
      #
      # == arguments
      # x
      #  Integer
      #   description: X coordinate of the target point. The coordinate is an absolute screen coordinate, relative to the display top left corner.
      #   example: 300
      #
      # y
      #  Integer
      #   description: Y coordinate of the target point. The coordinate is an absolute screen coordinate, relative to the display top left corner.
      #   example: 300
      #
      # button
      #  Symbol
      #   description: The mouse button pressed while the flick is executed can be defined. Please see [link="#buttons_table"]the buttons table[/link] for valid button symbols.
      #   example: :Middle
      #   default: :Left
      #
      # optional_params
      #  Hash
      #   description: The only optional argument supported by flick_to is :use_tap_screen.
      #   example: { :use_tap_screen => 'true' }
      #   default: { :use_tap_screen => 'false' }  
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid  	
	    def flick_to( x, y, button = :Left, optional_params = {})

		  begin
            use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
              optional_params[:use_tap_screen].to_s
            optional_params[:useTapScreen] = use_tap_screen

		    

		    speed = calculate_speed( @sut.parameter[ :gesture_flick_distance ], @sut.parameter[ :gesture_flick_speed ] )
		    do_gesture({:gesture_type => :MouseGestureToCoordinates, :x => x, :y => y, :speed => speed, :isDrag => false, :button => button, :useTapScreen => use_tap_screen})		
		    do_sleep(speed)

		  rescue Exception => e

		    $logger.log "behaviour" , "FAIL;Failed flick_to with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};drag;"
		    Kernel::raise e        
		  end      

		  $logger.log "behaviour" , "PASS;Operation flick_to executed successfully with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};drag;"

		  nil

	    end


	    # == description
      # Perform a gesture with the object
      #
      # == arguments
      # direction
      #  Symbol
      #   description: Direction of the gesture. Please see [link="#directions_table"]the directions table[/link] for valid direction symbols.  
      #   example: :Left
      #
      #  Integer
      #   description: Direction of the gesture as degrees with 0 being up and 90 right.
      #   example: 270
      #
      # speed
      #  Numeric
      #   description: Duration of the gesture in seconds. The value may be an interger or a fractional value as a floating point number.
      #   example: 1
      #
      # distance
      #  Integer
      #   description: Number of pixels that the object is to be moved in the gesture.
      #   example: 100
      #
      # optional_params
      #  Hash
      #   description: This method supports :use_tap_screen, :isDrag and :button optional arguments. The first two can be either true or false, for :button values please see [link="#buttons_table"]the buttons table[/link].
      #   example: { :button => :Right }
      #   default: { :use_tap_screen => 'false', :isDrag => false, :button => :Left }  
      #
      # == tables
	    # directions_table
	    #  title: Direction symbols table
      #  |Symbol|
      #  |:Left|
      #  |:Right|
      #  |:Up|
      #  |:Down|
      #
      # buttons_table
	    #  title: Mouse button symbols table
      #  |Symbol|Description|
      #  |:Left|Simulate left mouse button|
      #  |:Middle|Simulate middle mouse button|
      #  |:Right|Simulate right mouse button|
      #  |:NoButton|Do not simulate any mouse button|
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid    
	    def gesture( direction, speed, distance, optional_params = {:button => :Left, :isDrag => false}) 

		  begin
            # change the format for api consitency
            use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
              optional_params[:use_tap_screen].to_s
            optional_params[:useTapScreen] = use_tap_screen
            optional_params['x_off'] = $parameters[ @sut.id ][:tap_x_offset , '0' ],
            optional_params['y_off'] = $parameters[ @sut.id ][:tap_y_offset , '0' ]



		    #do_gesture(direction, speed, distance, isDrag, button)
		    params = {
		    	:gesture_type => :MouseGesture,
		    	:direction => direction,
		    	:speed => speed,
		    	:distance => distance
		    }
		    params.merge!(optional_params)
		    do_gesture(params)
		    do_sleep(speed)

		  rescue Exception => e

		    $logger.log "behaviour", 
			  "FAIL;Failed gesture with direction \"#{direction}\", speed \"#{speed.to_s}\", distance \"#{distance.to_s}\".;#{identity};gesture;"
		    Kernel::raise e        
		  end      

		  $logger.log "behaviour", 
		    "PASS;Operation gesture executed successfully with direction \"#{direction}\", speed \"#{speed.to_s}\", distance \"#{distance.to_s}\".;#{identity};gesture;"

		  nil
	    end

	    # == description
      # Perform a gesture with the object, ending the gesture at the specified point.
      #
      # == arguments
      # x
      #  Integer
      #   description: X coordinate of the target point. The coordinate is an absolute screen coordinate, relative to the display top left corner.
      #   example: 300
      #
      # y
      #  Integer
      #   description: Y coordinate of the target point. The coordinate is an absolute screen coordinate, relative to the display top left corner.
      #   example: 300
      #
      # speed
      #  Numeric
      #   description: Duration of the gesture in seconds. The value may be an interger or a fractional value as a floating point number.
      #   example: 1
      #
      # optional_params
      #  Hash
      #   description: This method supports :use_tap_screen, :isDrag and :button optional arguments. The first two can be either true or false, for :button values please see [link="#buttons_table"]the buttons table[/link].
      #   example: { :button => :Right }
      #   default: { :use_tap_screen => 'false', :isDrag => false, :button => :Left }  
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid   
        def gesture_to(x, y, speed, optional_params = {:button => :Left, :isDrag => false})

          begin      
            # change the format for api consitency
            use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
              optional_params[:use_tap_screen].to_s
            optional_params[:useTapScreen] = use_tap_screen

            params = {:gesture_type => :MouseGestureToCoordinates, :speed => speed}
            if attribute('objectType') == 'Web'
			  elemens_xml_data, unused_rule = TDriver::TestObjectAdapter.get_objects( @sut.xml_data, { :id => self.attribute('webFrame')}, true )
			  object_xml_data = elemens_xml_data[0]
			  object_attributes = TDriver::TestObjectAdapter.test_object_attributes(object_xml_data, ['x_absolute', 'y_absolute'])
              frame_x_absolute = object_attributes['x_absolute'].to_i
              frame_y_absolute = object_attributes['y_absolute'].to_i
              new_params = {:x=>(frame_x_absolute + x.to_i + (attribute('width' ).to_i/2)),
                            :y=>(frame_y_absolute + y.to_i + (attribute('height').to_i/2))}
              params.merge!(new_params)
            else
              new_params = {:x=>x, :y=>y}
              params.merge!(new_params)
            end
            
            
            params.merge!(optional_params)
            do_gesture(params)
            do_sleep(speed) 

          rescue Exception => e

            $logger.log "behaviour" , "FAIL;Failed gesture_to with x \"#{x}\", y \"#{y}\", speed \"#{speed.to_s}\", button \".;#{identity};gesture;"
            Kernel::raise e        
          end

          $logger.log "behaviour" , "PASS;Operation gesture_to executed successfully with x \"#{x}\", y \"#{y}\", speed \"#{speed.to_s}\".;#{identity};gesture;"
          nil
        end

    	# == description
      # Perform a gesture with the object, starting the gesture at the specified point inside it.
      #
      # == arguments
      # x
      #  Integer
      #   description: X coordinate of the start point. The coordinate is relative to the object top left corner.
      #   example: 20
      #
      # y
      #  Integer
      #   description: Y coordinate of the start point. The coordinate is relative to the object top left corner.
      #   example: 15
      #
      # speed
      #  Numeric
      #   description: Duration of the gesture in seconds. The value may be an interger or a fractional value as a floating point number.
      #   example: 1
      #
      # direction
      #  Symbol
      #   description: Direction of the gesture. Please see this table for valid direction symbols.  
      #   example: :Left
      #
      #  Integer
      #   description: Direction of the gesture as degrees with 0 being up and 90 right.
      #   example: 270
      #
      # distance
      #  Integer
      #   description: Number of pixels that the object is to be moved in the gesture.
      #   example: 100
      #
      # optional_params
      #  Hash
      #   description: This method supports :use_tap_screen, :isDrag and :button optional arguments. The first two can be either true or false, for :button values please see [link="#buttons_table"]the buttons table[/link].
      #   example: { :button => :Right }
      #   default: { :use_tap_screen => 'false', :isDrag => false, :button => :Left }  
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid, or the initial point is outside the target object.
      #
	    def gesture_from(x, y, speed, distance, direction, optional_params = {:button => :Left, :isDrag => false})
		  begin
		    raise ArgumentError.new( "Coordinate x:#{x} x_abs:#{x} outside object." ) unless ( x <= attribute( 'width' ).to_i and x >= 0 )
		    raise ArgumentError.new( "Coordinate y:#{y} y_abs:#{y} outside object." ) unless ( y <= attribute( 'height' ).to_i and y >= 0 )
		    
		    x_absolute = attribute('x_absolute').to_i + x.to_i 
		    y_absolute = attribute('y_absolute').to_i + y.to_i 

            params = {:gesture_type => :MouseGestureFromCoordinates, :x => x_absolute, :y => y_absolute, :speed => speed, :distance => distance, :direction => direction}

            params.merge!(optional_params)
		    do_gesture(params)
		    do_sleep(speed) 


		  rescue Exception => e      
		    $logger.log "behaviour" , "FAIL;Failed gesture_from with x \"#{x}\", y \"#{y}\", speed \"#{speed.to_s}\", distance \"#{distance.to_s}\", button \".;#{identity};gesture;"
		    Kernel::raise e        
		  end
		  $logger.log "behaviour" , "PASS;Operation gesture_from executed successfully with x \"#{x}\", y \"#{y}\", speed \"#{speed.to_s}\", distance \"#{distance.to_s}\".;#{identity};gesture;"
		  nil
	    end

	    # == description
      # Perform a gesture with the object, ending the gesture at the center of another object.
      #
      # == arguments
      # target_object
      #  TestObject
      #   description: The object where the gesture should end.
      #   example: @app.Node
      #
      # duration
      #  Numeric
      #   description: Duration of the gesture in seconds. The value may be an interger or a fractional value as a floating point number.
      #   example: 1
      #
      # optional_params
      #  Hash
      #   description: This method supports :use_tap_screen, :isDrag and :button optional arguments. The first two can be either true or false, for :button values please see [link="#buttons_table"]the buttons table[/link].
      #   example: { :button => :Right }
      #   default: { :use_tap_screen => 'false', :isDrag => false, :button => :Left }  
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid  
	    def gesture_to_object(target_object, duration, optional_params = {:button => :Left, :isDrag => false})    
            if attribute('objectType') == 'Web'
              gesture_to(target_object.attribute('x').to_i + (target_object.attribute('width' ).to_i/2) - (attribute('width' ).to_i/2),
                         target_object.attribute('y').to_i + (target_object.attribute('height').to_i/2) - (attribute('height').to_i/2),
                         duration, optional_params)
              nil
              return 
            end

		  begin
            # change the format for api consitency
            use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
              optional_params[:use_tap_screen].to_s
            optional_params[:useTapScreen] = use_tap_screen



            params = {:gesture_type => :MouseGestureTo, :speed => duration}
            params[:targetId] = target_object.id
            params[:targetType] = target_object.attribute('objectType')
            params.merge!(optional_params)
            do_gesture(params)
            do_sleep(duration)

		  rescue Exception => e      

		    $logger.log "behaviour" , "FAIL;Failed gesture_to_object with button.;#{identity};drag;"
		    Kernel::raise e        

		  end      

		  $logger.log "behaviour" , "PASS;Operation gesture_to_object executed successfully with button.;#{identity};drag;"

		  nil

	    end

      # == description
      # Perform a gesture following a track of points.
      #
      # == arguments
      # points
      #  Array
      #   description: Each element of this Array defines a point of the gesture as a Hash. Three keys with Integer values are defined for a point: the coordinate as "x" and "y" keys and "interval" as seconds (Note that this is likely a very short time, i.e. fraction of a second).
      #   example: [{"x" => 200,"y" => 100, "interval" => 0.15},{"x" => 200,"y" => 110, "interval" => 0.30}]
      #
      # duration
      #  Numeric
      #   description: Duration of the gesture in seconds. The value may be an interger or a fractional value as a floating point number.
      #   example: 1
      #
      # mouse_details
      #  Hash
      #   description: Mouse usage details can be defined by setting the :press, :release and :isDrag keys to true or false. Valid values for the :button key are described in [link="#buttons_table"]the buttons table[/link].
      #   example: { :press => true, :release => true, :button => :Right, :isDrag => false}
      #   default: { :press => true, :release => true, :button => :Left, :isDrag => true}  
      #
      # optional_params
      #  Hash
      #   description: This method only supports the :use_tap_screen optional parameter.
      #   example: { :use_tap_screen => true }  
      #   default: { :use_tap_screen => false }  
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid
	    def gesture_points( points, duration, mouse_details = { :press => true, :release => true, :button => :Left, :isDrag => true}, optional_params = {} )

		    begin

          use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
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

		      $logger.log "behaviour", 
			    "FAIL;Failed drag_to_object with points \"#{points.to_s}\", duration \"#{duration.to_s}\", mouse_details \"#{mouse_details.to_s}\".;#{identity};gesture_points;"
		      Kernel::raise e        

		    end      

		    $logger.log "behaviour", 
		      "PASS;Operation drag_to_object executed successfully with points \"#{points.to_s}\", duration \"#{duration.to_s}\", mouse_details \"#{mouse_details.to_s}\".;#{identity};gesture_points;"

		    nil
	    end

	    # == description
      # Drag the object for the given distance.      
      # By default a drag is a slow gesture.
      #
      # == arguments
      # direction
      #  Symbol
      #   description: Direction of the drag. Please see [link="#directions_table"]the directions table[/link] for valid direction symbols.  
      #   example: :Left
      #
      #  Integer
      #   description: Direction of the drag as degrees with 0 being up and 90 right.
      #   example: 270
      #
      # distance
      #  Integer
      #   description: Number of pixels that the object is to be dragged.
      #   example: 100
      #
      # button
      #  Symbol
      #   description: The mouse button pressed while the drag is executed can be defined. Please see [link="#buttons_table"]the buttons table[/link] for valid button symbols.
      #   example: :Right
      #   default: :Left
      #
      # optional_params
      #  Hash
      #   description: The only optional argument supported by drag is :use_tap_screen.
      #   example: { :use_tap_screen => 'true' }
      #   default: { :use_tap_screen => 'false' }  
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid  
	    def drag(direction, distance, button = :Left, optional_params = {})

		  begin
            use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
              optional_params[:use_tap_screen].to_s
            optional_params[:useTapScreen] = use_tap_screen

		    speed = calculate_speed( distance, @sut.parameter[ :gesture_drag_speed ] )
            params = {:gesture_type => :MouseGesture, :direction => direction, :speed => speed, :distance => distance, :isDrag => true, :button => button}
            params.merge!(optional_params)
            do_gesture(params)		
		    do_sleep( speed )

		  rescue Exception => e      
		    
		    $logger.log "behaviour" , "FAIL;Failed drag with direction \"#{direction}\", distance \"#{distance}\", button \"#{button.to_s}\".;#{identity};drag;"
		    Kernel::raise e        

		  end      

		  $logger.log "behaviour" , "PASS;Operation drag executed successfully with direction \"#{direction}\", distance \"#{distance}\", button \"#{button.to_s}\".;#{identity};drag;"

		  nil
	    end
      
      # == description
      # Drag the object to the given coordinates.
      # By default a drag is a slow gesture.
      #
      # == arguments
      # x
      #  Integer
      #   description: X coordinate of the target point. The coordinate is an absolute screen coordinate, relative to the display top left corner.
      #   example: 300
      #
      # y
      #  Integer
      #   description: Y coordinate of the target point. The coordinate is an absolute screen coordinate, relative to the display top left corner.
      #   example: 300
      #
      # button
      #  Symbol
      #   description: The mouse button pressed while the drag is executed can be defined. Please see [link="#buttons_table"]the buttons table[/link] for valid button symbols.
      #   example: :Right
      #   default: :Left
      #
      # optional_params
      #  Hash
      #   description: The only optional argument supported by drag_to is :use_tap_screen.
      #   example: { :use_tap_screen => 'true' }
      #   default: { :use_tap_screen => 'false' }  
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid  
	    def drag_to( x, y, button = :Left, optional_params= {} )

        begin
          optional_params.merge!({ :isDrag => true , :button=>button})
          distance = distance_to_point(x,y)
          speed = calculate_speed(distance, @sut.parameter[:gesture_drag_speed])
          gesture_to(x, y, speed, optional_params )

        rescue Exception => e      
          $logger.log "behaviour" , "FAIL;Failed drag_to with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};drag;"
          Kernel::raise e        
        end      

        $logger.log "behaviour" , "PASS;Operation drag_to executed successfully with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};drag;"

        nil

      end

      # == description
      # Drag the object to the center of another object.
      # By default a drag is a slow gesture.
      #
      # == arguments
      # target_object
      #  TestObject
      #   description: The object that this object should be dragged to.
      #   example: @app.Node
      #
      # button
      #  Symbol
      #   description: The mouse button pressed while the drag is executed can be defined. Please see [link="#buttons_table"]the buttons table[/link] for valid button symbols.
      #   example: :Right
      #   default: :Left
      #
      # optional_params
      #  Hash
      #   description: The only optional argument supported by drag_to_object is :use_tap_screen.
      #   example: { :use_tap_screen => 'true' }
      #   default: { :use_tap_screen => 'false' }  
      #
      # == returns
      # NilClass
      #   description: Always returns nil
      #   example: nil
      #
      # == exceptions
      # ArgumentError
      #   description: One of the arguments is not valid   
	    def drag_to_object(target_object, button = :Left, optional_params = {})       

		    begin

          use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
          optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen

		      distance = distance_to_point(target_object.object_center_x, target_object.object_center_y)
		      #no drag needed, maybe even attempting to drag to it self
		      return if distance == 0

		      speed = calculate_speed(distance, @sut.parameter[:gesture_drag_speed])
          params = {:gesture_type => :MouseGestureTo, :speed => speed, :isDrag => true, :button => button}
          params[:targetId] = target_object.id
          params[:targetType] = target_object.attribute('objectType')
          params.merge!(optional_params)
          do_gesture(params)
		      do_sleep(speed)

		    rescue Exception => e      

		      $logger.log "behaviour" , "FAIL;Failed drag_to_object with button \"#{button.to_s}\".;#{identity};drag;"
		      Kernel::raise e        

		    end      

		    $logger.log "behaviour" , "PASS;Operation drag_to_object executed successfully with button \"#{button.to_s}\".;#{identity};drag;"

		    nil

	    end
      
	    # == description
      # Perform a pointer move starting at the object
      #
      # == arguments
      # direction
      #  Symbol
      #   description: Direction of the move. Please see [link="#directions_table"]the directions table[/link] for valid direction symbols.  
      #   example: :Left
      #
      #  Integer
      #   description: Direction of the move as degrees with 0 being up and 90 right.
      #   example: 270
      #
      # distance
      #  Integer
      #   description: Number of pixels to be moved.
      #   example: 100
      #
      # button
      #  Symbol
      #   description: The mouse button used with the move can be defined. Please see [link="#buttons_table"]the buttons table[/link] for valid button symbols.
      #   example: :Right
      #   default: :Left
      #
      # optional_params
      #  Hash
      #   description: The only optional argument supported by drag_to_object is :use_tap_screen.
      #   example: {:use_tap_screen => 'true'}
      #   default: {:use_tap_screen => 'false'}  
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: nil
      #
      # == exceptions
      # ArgumentError
      #  description: One of the arguments is not valid    
	    def move(direction, distance, button = :Left, optional_params = {})

		    begin

          use_tap_screen = optional_params[:use_tap_screen].nil? ? $parameters[ @sut.id][ :use_tap_screen, 'false'] :
          optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen

		      speed = calculate_speed( distance, @sut.parameter[ :gesture_drag_speed ] )
          params = {:gesture_type => :MouseGesture, :direction => direction, :speed => speed, :distance => distance, :isDrag => false, :button => button, :isMove => true}
          params.merge!(optional_params)
          do_gesture(params)
		      do_sleep( speed )

		    rescue Exception => e      

		      $logger.log "behaviour" , "FAIL;Failed move with direction \"#{direction}\", distance \"#{distance}\",.;#{identity};move;"
		      Kernel::raise e        

		    end      

		    $logger.log "behaviour" , "PASS;Operation move executed successfully with direction \"#{direction}\", distance \"#{distance}\",.;#{identity};move;"

		    nil
	    end
       

      # == nodoc
	    # utility function for getting the x coordinate of the center of the object, should this be private method?
	    def object_center_x
  		  center_x
	    end

      # == nodoc
	    # utility function for getting the y coordinate of the center of the object, should this be private method?
	    def object_center_y
  		  center_y
	    end  

	    


	    private

	    # Performs the actual gesture operation. 
	    # Verifies that the parameters are correct and send the command
	    # to the sut. 
	    # gesture_type: :MouseGesture, :MouseGestureTo, :MouseGestureToCoordinates
	    # params = {:direction => :Up, duration => 2, :distance =>100, :isDrag =>false, :isMove =>false }
	    def do_gesture(params)
		    validate_gesture_params!(params)

		    if attribute('objectType') == 'Embedded' or attribute('objectType') == 'Web'
		      params['obj_x'] = center_x
		      params['obj_y'] = center_y
		      params['useCoordinates'] = 'true'
		    end

		    command = command_params #in qt_behaviour           
		    command.command_name(params[:gesture_type].to_s)
		    command.command_params( params )
		    @sut.execute_command( command )
	    end

	    def validate_gesture_params!(params)
		    #direction		
		    if params[:gesture_type] == :MouseGesture or params[:gesture_type] == :MouseGestureFromCoordinates
		      if params[:direction].kind_of?(Integer)
			    raise ArgumentError.new( "Invalid direction." ) unless 0 <= params[:direction].to_i and params[:direction].to_i <= 360 
		      else
			    raise ArgumentError.new( "Invalid direction." ) unless @@_valid_directions.include?(params[:direction])  
			    params[:direction] = @@_direction_map[params[:direction]]
		      end
		      #distance
		      params[:distance] = params[:distance].to_i unless params[:distance].kind_of?(Integer)
		      raise ArgumentError.new( "Distance must be an integer and greater than zero." ) unless  params[:distance] > 0
		    elsif params[:gesture_type] == :MouseGestureToCoordinates or params[:gesture_type] == :MouseGestureFromCoordinates
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

		    if $parameters[ @sut.id ][ :sleep_disabled, nil ] != 'true'
		      time = time.to_f
		      time = time * 1.3
		      #for flicks the duration of the gesture is short but animation (scroll etc..) may not
		      #so wait at least one second
		      time = 1 if time < 1	
		      sleep time
		    else
		      #store the biggest value which will then be used in multitouch situations to sleep
		      $parameters[ @sut.id ][ :skipped_sleep_time ] = time if time > $parameters[ @sut.id ][ :skipped_sleep_time, 0]
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
	    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	  end

  end
end
