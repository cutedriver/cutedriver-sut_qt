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

	module Multitouch

	  include MobyBehaviour::QT::Behaviour

	  # Performs a pinch zoom in operation. The distance of the operation is 
	  # is for both fingers. So a distance of 100 will be performed by both
	  # fingers.
	  # see pinch_zoom
	  def pinch_zoom_in(speed, distance, direction)
		pinch_zoom({:type => :in, :speed => speed, :distance_1 => distance, :distance_2 => distance, :direction => direction, :differential => 10})
	  end

	  # Performs a pinch zoom out operation. The distance of the operation is 
	  # is for both fingers. So a distance of 100 will be performed by both
	  # fingers.
	  # see pinch_zoom
	  def pinch_zoom_out(speed, distance, direction)
		pinch_zoom({:type => :out, :speed => speed, :distance_1 => distance, :distance_2 => distance, :direction => direction, :differential => 10})
	  end

	  # Performs two gesture operations at the same time
	  # causing a pinch zoom affect in components supporting 
	  # pinch zoom.
	  # == params
	  # params: a hash containing the details of the pinch zoom. Required fields:
	  # :type  values: :in, :out type of the zoom in or out 
	  # :speed speed/duration in seconds
	  # :distance_1 distance of the first finger zoom gesture
	  # :distance_2 distance of the second finger zoom gesture
	  # :direction direction of the total zoom operation seen as one line in degrees (0-180) or :Horisontal/:Vertical 
	  # :differential the difference from where the zoom starts or ends
	  # :x optional center point for the gesture (both required x and y)
	  # :y optional center point for the gesture (both required x and y)
	  # example
	  # app.MainWindow.pinch_zoom( {:type => :in, :speed => 2, :distance_1 => 100, :distance_2 => 100, :direction => 180, :differential => 10, :x => 1, :y => 1} )
	  def pinch_zoom(params)

		begin
		  verify_pinch_params!(params)

		  #convert speed to millis
		  time = params[:speed].to_f
		  speed = time*1000
		  params[:speed] = speed.to_i
		  if params['x'].kind_of?(Integer) and params['y'].kind_of?(Integer)
			params['useCoordinates'] = 'true' 
			params['x'] = attribute('x_absolute').to_i + params['x']
			params['y'] = attribute('y_absolute').to_i + params['y']
		  end
		  command = command_params #in qt_behaviour           
		  command.command_name('PinchZoom')
		  command.command_params(params)

		  @sut.execute_command( command )

		  #wait untill the pinch is finished
		  do_sleep(time)

		rescue Exception => e      
		  MobyUtil::Logger.instance.log "behaviour","FAIL;Failed pinch_zoom with params \"#{params.to_s}\".;#{identity};pinch_zoom;"
		  Kernel::raise e        
		end      
		MobyUtil::Logger.instance.log "behaviour","PASS;Operation pinch_zoom succeeded with params \"#{params.to_s}\".;#{identity};pinch_zoom;"
		nil	
	  end

	  #Rotation done around a center point holding the center point (one end moving)
	  def one_point_rotate(radius, start_angle, rotate_direction, distance, speed, center_point = nil)
		params = {:type => :one_point, :radius => radius, :rotate_direction => rotate_direction, :distance => distance, :speed => speed, :direction => start_angle}
		params.merge!(origin_point) if center_point 
		rotate(params)
	  end
	  
	  #Rotatation around a center point (both ends moving)
	  def two_point_rotate(radius, start_angle, rotate_direction, distance, speed, center_point = nil)
		params = {:type => :two_point, :radius => radius, :rotate_direction => rotate_direction, :distance => distance, :speed => speed, :direction => start_angle}
		params.merge!(origin_point) if center_point 
		rotate(params)
	  end

	  # {:type => :one_point, :radius => 100, :rotate_direction => :Clockwise, :distance => 45, :speed => 2, :direction => 35, :x => 2, y => 35}
	  def rotate(params)
		begin
		  verify_rotate_params!(params)

		  time = params[:speed].to_f
		  speed = time*1000
		  params[:speed] = speed.to_i

		  if params['x'].kind_of?(Integer) and params['y'].kind_of?(Integer)
			params['useCoordinates'] = 'true' 
			params['x'] = attribute('x_absolute').to_i + params['x']
			params['y'] = attribute('y_absolute').to_i + params['y']
		  end

		  command = command_params #in qt_behaviour           
		  command.command_name('Rotate')
		  command.command_params(params)
		  
		  @sut.execute_command( command )
		  
		  #wait untill the pinch is finished
		  do_sleep(time)
		rescue Exception => e      
		  MobyUtil::Logger.instance.log "behaviour","FAIL;Failed rotate with params \"#{params.to_s}\".;#{identity};rotate;"
		  Kernel::raise e        
		end      
		MobyUtil::Logger.instance.log "behaviour","PASS;Operation rotate succeeded with params \"#{params.to_s}\".;#{identity};rotate;"
		nil
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
	MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


	end
  end
end
