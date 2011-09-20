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
    # Behaviours for multitouch operations. 
    #
    # == behaviour
    # QtMultitouch
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # touch
    #
    # == sut_type
    # qt
    #
    # == sut_version
    # *
    #
    # == objects
    # *
    #
	  module Multitouch

	    include MobyBehaviour::QT::Behaviour

        # == description
        # Performs a pinch zoom in operation. The distance of the operation is 
        # is for both fingers. So a distance of 100 will be performed by both
        # end points (fingers).
        #
        # == arguments
        # speed
        #  Integer
        #   description: Speed of the operation in seconds
        #   example: 3
        #
        # distance
        #  Integer
        #   description: Distance of the pinch zoom
        #   example: 100
        #
        # direction
        #  Integer
        #   description: Direction of the pinch zoom in degrees 0-180
        #   example: 90
        #  Symbol
        #   description: Direction of the pinch zoom either :Horizontal or :Vertical
        #   example: :Horizontal
        #
        # differential
        #  Integer
        #   description: The difference from where the zoom starts or ends (how far apart are the fingers when starting the zoom)
        #   example: 10
        #
        # == returns
        # NilClass
        #   description: -
        #   example: -
        #
        # == exceptions
        # ArgumentError
        #  description:  In case the given parameters are not valid.
        #    
        # == info
        # See method pinch_zoom
        #
	      def pinch_zoom_in(speed, distance, direction, differential = 10)

      		pinch_zoom({:type => :in, :speed => speed, :distance_1 => distance, :distance_2 => distance, :direction => direction, :differential => differential})

          self

	      end

        # == description
        # Performs a pinch zoom out operation. The distance of the operation is 
        # is for both fingers. So a distance of 100 will be performed by both
        # fingers.
        #
        # == arguments
        # speed
        #  Integer
        #   description: Speed of the operation in seconds
        #   example: 3
        #
        # distance
        #  Integer
        #   description: Distance of the pinch zoom
        #   example: 100
        #
        # direction
        #  Integer
        #   description: Direction of the pinch zoom in degrees 0-180
        #   example: 90
        #  Symbol
        #   description: Direction of the pinch zoom either :Horizontal or :Vertical
        #   example: :Horizontal
        #
        # differential
        #  Integer
        #   description: The difference from where the zoom starts or ends (how far apart are the fingers when starting the zoom)
        #   example: 10
        #
        # == returns
        # NilClass
        #   description: -
        #   example: -
        #
        # == exceptions
        # ArgumentError
        #  description:  In case the given parameters are not valid.
        #    
        # == info
        # See method pinch_zoom
        #
	      def pinch_zoom_out(speed, distance, direction, differential = 10)

      		pinch_zoom({:type => :out, :speed => speed, :distance_1 => distance, :distance_2 => distance, :direction => direction, :differential => differential})

          self

	      end

        # == description
        # Causes a pinch zoom gesture on the object. The type of the pinch is based on the given parameters. 
        # The parameters make it possible to define various kinds of pinch zoom operations.
        #
        # The image shows how the different parameters will be used to make the pinch gesture. 
        # The image show a zoom in type gesture (:type => :in). Direction is the angle of the 
        # first part of the pinch gesture against the y axel (0 degrees is up). Distance variables 
        # do not have to be the same. This means that you can set the gesture so that one finger 
        # moves a longer distance than the other (or even set one distance to 0). 
        # The :differential parameter determines the how close the nearest points 
        # in the pinch gesture are (:in start points and :out end points). 
        # The center points can be set using the :x and :y setting. 
        # The values are relative to the object and if not set then the center point of the object is used.
        # \n
        # [img="images/pinch.png"]Pinch zoom parameters[/img]
        #
        # == arguments
        # params
        #  Hash 
        #   description:
        #    A Hash table contains all of the parameters required to make the pinch zoom. 
        #    See [link="#pinch_options_table"]Pinch options table[/link] for valid keys. 
        #    example: pinch_zoom({:type => :in, :speed => 2, :distance_1 => 100, :distance_2 => 100, :direction => :Vertical, :differential => 10})
        #
        # == tables
        # pinch_options_table
        #  title: Pinch options table
        #  |Key|Type|Description|Accepted values|Example|Required|
        #  |:type|Symbol|Zoom in or out|:in,:out|:type => :in|Yes|
        #  |:speed|Integer|Speed of the gesture in seconds|Positive Integer|:speed => 2|Yes|
        #  |:distance_1|Integer|Distance of the first finger zoom gesture|Positive integer|:distance_1 => 100|Yes|
        #  |:distance_2|Integer|Distance of the second finger zoom gesture|Positive integer|:distance_2 => 100|Yes|
        #  |:differential|Integer|The difference from where the zoom starts or ends|Positive integer|:differential => 10|Yes|
        #  |:x|Integer|X coordinate of the center point for the pinch (relative to the object). Optional defaults to center point but if set y must also be set.|Positive Integer| :x => 120|No|
        #  |:y|Integer|Y coordinate of the center point for the pinch (relative to the object). Optional defaults to center point but if set x must also be set.|Positive Integer|:y => 200|No|
        #
        # == returns
        # NilClass
        #   description: -
        #   example: -
        #
        # == exceptions
        # ArgumentError
        #  description:  In case the given parameters are not valid.
        #    
	      def pinch_zoom( params )

		      begin
		        verify_pinch_params!(params)

		        #convert speed to millis
		        time = params[:speed].to_f
		        speed = time*1000
		        params[:speed] = speed.to_i
		        if params[:x].kind_of?(Integer) and params[:y].kind_of?(Integer)
			      params[:useCoordinates] = 'true' 
			      params[:x] = attribute('x_absolute').to_i + params[:x]
			      params[:y] = attribute('y_absolute').to_i + params[:y]
		        end
		        command = command_params #in qt_behaviour           
		        command.command_name('PinchZoom')
		        command.command_params(params)

		        @sut.execute_command( command )

		        #wait untill the pinch is finished
		        do_sleep(time)

		      rescue Exception => e      
		        $logger.behaviour "FAIL;Failed pinch_zoom with params \"#{ params.inspect }\".;#{ identity };pinch_zoom;"
		        raise e        
		      end      

		      $logger.behaviour "PASS;Operation pinch_zoom succeeded with params \"#{ params.inspect }\".;#{ identity };pinch_zoom;"

		      self

	      end

        # == description
        # Causes rotation motion on the object. The rotation will be so that one point is stationary 
        # while other moves to create a rotation motion (like a hinge).
        #
        # == arguments
        # radius
        #  Integer
        #   description: Radius of the of the rotation in degrees (distance between the points)
        #   example: 100
        #
        # start_angle
        #  Integer
        #   description: Starting angle of the rotation. Integer from 0-360
        #   example: 90
        #  Symbol
        #   description: Starting angle of the rotation. Symbol :Horizontal or :Vertical
        #   example: :Horizontal
        #
        # rotate_direction
        #  Symbol
        #   description: Rotation direction :Clockwise or :CounterClockwise. 
        #   example: :CounterClockwise
        #
        # distance
        #  Integer
        #   description: Distance of the rotation in degrees
        #   example: 360
        #
        # speed
        #  Integer
        #   description: Speed in seconds
        #   example: 3
        #
        # center_point
        #  Hash
        #   description: Optional X and Y coordinates (relative to the object e.g. top left of the object is 0.0). 
        #                In one point rotation the other end point will remain stationary (the rotation is done around that point)
        #                and that will be the given point. If not given the point will be the center of the object.
        #   example: {:x => 50, :y => 100}
        #
        # == returns
        # NilClass
        #   description: -
        #   example: -
        #
        #
        # == exceptions
        # ArgumentError
        #  description:  In case the given parameters are not valid.
        #    
        # == info
        # See [link="#QtMultitouch:rotate"]rotate[/link] method for more details
        #
	      def one_point_rotate(radius, start_angle, rotate_direction, distance, speed, center_point = nil)
		      params = {:type => :one_point, :radius => radius, :rotate_direction => rotate_direction, :distance => distance, :speed => speed, :direction => start_angle}
		      params.merge!(center_point) if center_point 
		      rotate(params)
          self
	      end
	    
        # == description
        # Causes ratation motion on the object. The rotation will be so that both ends move to create a rotation motion around a point.
        #
        # == arguments
        # radius
        #  Integer
        #   description: Radius of the of the rotation in degrees (distance between the points)
        #   example: 100
        #
        # start_angle
        #  Integer
        #   description: Starting angle of the rotation. Integer from 0-360
        #   example: 90
        #  Symbol
        #   description: Starting angle of the rotation. Symbol :Horizontal or :Vertical
        #   example: :Horizontal
        #
        # rotate_direction
        #  Symbol
        #   description: Rotation direction :Clockwise or :CounterClockwise. 
        #   example: :CounterClockwise
        #
        # distance
        #  Integer
        #   description: Distance of the rotation in degrees
        #   example: 360
        #
        # speed
        #  Integer
        #   description: Speed in seconds
        #   example: 3
        #
        # center_point
        #  Hash
        #   description: Optional X and Y coordinates (relative to the object e.g. top left of the object is 0.0). 
        #                In two point rotation both end points will rotate around a center point which will be
        #                the given point. If not given the point will be the center of the object.
        #   example: {:x => 50, :y => 100}
        #
        # == returns
        # NilClass
        #   description: -
        #   example: -
        #
        # == exceptions
        #
        # ArgumentError
        #  description:  In case the given parameters are not valid.
        #    
        # == info
        # See method rotate
        #
	      def two_point_rotate(radius, start_angle, rotate_direction, distance, speed, center_point = nil)
		      params = {:type => :two_point, :radius => radius, :rotate_direction => rotate_direction, :distance => distance, :speed => speed, :direction => start_angle}
		      params.merge!(center_point) if center_point 
		      rotate(params)
          self
	      end

        # == description
        # Causes a rotate motion on the screen using two fingers (e.g. like turning a knob). Similar gesture to pinch zooming except the angle changes.
        # \n
        # \n
        # [img="images/rotate.png"]Rotation parameters[/img]
        # \n
        # The image shows how the different parameters will be used to make the rotation gestures in both 
        # one point and two point rotations. In one point rotation the other end remains stationary while 
        # the other moves around it based on the given radius. In two point rotation the movement is done 
        # by both ends. Note the direction paramters as the :direction parameter defines the starting angle 
        # for the gesture and :rotation_direction defines the actual rotation direction (clockwise or counter clockwise). 
        # When performing two point rotation note that the radius is in fact a radius not the diameter. 
        # Distance is given in degrees from 0-360. Center point can be set using :x and :y and if 
        # not set the center point of the object will be used.
        #
        # == arguments
        # params
        #  Hash
        #   description: A hash of the parameters that define the rotation. See [link="#rotate_options_table"]Rotate options table[/link] for valid keys
        #
        #   example: {:type => :one_point, :radius => 100, :rotate_direction => :Clockwise, :distance => 45, :speed => 2, :direction => 35, :x => 2, y => 35}
        #
        # == tables
        # rotate_options_table
        #  title: Rotate options table
        #  |Key|Type|Description|Accepted values|Example|Required|
        #  |:type|Symbol|Rotation type|:one_point,:two_point|:type => :one_point|Yes|
        #  |:radius|Integer|Radius of the rotatation in pixels|Any positive Integer|:radius => 100|Yes|
        #  |:rotation_direction|Symbol|Rotation direction|:Clockwise, :CounterClockwise|:rotate_direction => :Clockwise|Yes|
        #  |:distance|Integer|Rotation distance in degrees|0-360|:distance => 90|Yes|
        #  |:speed|Integer|Speed of the gesture in seconds|Positive Integer|:speed => 2|Yes|
        #  |:direction|Integer/Symbol|The start angle of the rotation.|0-360 or :Horizontal, :Vertical|:direction => 35|Yes|
        #  |:x|Integer|X coordinate of the center point for the pinch (relative to the object). Optional defaults to center point but if set y must also be set.|Positive Integer|:x => 50|No|
        #  |:y|Integer|Y coordinate of the center point for the pinch (relative to the object). Optional defaults to center point but if set x must also be set.|Positive Integer|:y => 120|No|
        #	  
        #
        # == returns
        # NilClass
        #   description: -
        #   example: -
        #
        # == exceptions
        #
        # ArgumentError
        #  description:  In case the given parameters are not valid.
        #    
	    def rotate(params)

		    begin

		      verify_rotate_params!(params)

		      time = params[:speed].to_f

		      params[:speed] = (time * 1000).to_i 


		      if params[:x].kind_of?(Integer) and params[:y].kind_of?(Integer)
			      params[:useCoordinates] = 'true' 
			      params[:x] = attribute('x_absolute').to_i + params[:x]
			      params[:y] = attribute('y_absolute').to_i + params[:y]
		      end

		      command = command_params #in qt_behaviour           
		      command.command_name('Rotate')
		      command.command_params(params)
		      
		      @sut.execute_command( command )
		      
		      #wait untill the operation to finish
		      do_sleep( time )
		    rescue Exception => e      
		      $logger.behaviour "FAIL;Failed rotate with params \"#{ params.inspect }\".;#{ identity };rotate;"
		      raise e        
		    end      

		    $logger.behaviour "PASS;Operation rotate succeeded with params \"#{ params.inspect }\".;#{ identity };rotate;"

		    self

	    end

    private

	    def verify_rotate_params!(params)
		    raise ArgumentError.new( "Invalid type allowed valued(:sector, :acrs)." ) unless params[:type] == :one_point or params[:type] == :two_point
		    raise ArgumentError.new("Speed must be a number.") unless params[:speed].kind_of?(Numeric)

		    #direction
		    if params[:direction].kind_of?(Integer)
		      raise ArgumentError.new("Direction must be between 0 and 360.") unless params[:direction] >= 0 and params[:direction] < 360
		    else    
		      raise ArgumentError.new( "Invalid direction." ) unless @@_pinch_directions.include?(params[:direction])  
		      params[:direction] = @@_pinch_directions[params[:direction]]
		    end

		    raise ArgumentError.new("Distance must be an integer.") unless params[:distance].kind_of?(Integer)   
		    raise ArgumentError.new("Distance must be between 0 and 360") unless params[:distance] > 0 and params[:distance] <= 360

		    raise ArgumentError.new("Invalid direction must be " + @@_rotate_direction.to_s) unless @@_rotate_direction.include?(params[:rotate_direction])
		    raise ArgumentError.new("Radius must be an integer.") unless params[:radius].kind_of?(Integer)
	    end

	    def verify_pinch_params!(params)
		    #type
		    raise ArgumentError.new( "Invalid type allowed valued(:in, :out)." ) unless params[:type] == :in or params[:type] == :out
		    #speed 
		    raise ArgumentError.new("Speed must be a number.") unless params[:speed].kind_of?(Numeric)
		    #distance
		    raise ArgumentError.new("Distance 1 must be an integer.") unless params[:distance_1].kind_of?(Integer)
		    raise ArgumentError.new("Distance 2 must be an integer.") unless params[:distance_2].kind_of?(Integer)
		    #direction
		    if params[:direction].kind_of?(Integer)
		      raise ArgumentError.new( "Invalid direction." ) unless 0 <= params[:direction].to_i and params[:direction].to_i <= 180 
		    else    
		      raise ArgumentError.new( "Invalid direction." ) unless @@_pinch_directions.include?(params[:direction])  
		      params[:direction] = @@_pinch_directions[params[:direction]]
		    end
		    #differential
		    raise ArgumentError.new("Differential must be an integer.") unless params[:differential].kind_of?(Integer)
	    end

	    # enable hooking for performance measurement & debug logging
	    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	  end # Multitouch

  end # QT

end # MobyBehaviour
