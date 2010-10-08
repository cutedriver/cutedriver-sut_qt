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

include TDriverVerify

# Application behaviour for Qt
module MobyBehaviour

  module QT

	module Application

	  def drag( start_x, start_y, end_x, end_y, duration = 1000 )

		@sut.execute_command( MobyCommand::Drag.new( start_x, start_y, end_x, end_y, duration ) )

	  end

	  # Kills the application process
	  # Currently only for QT
	  def kill

		@sut.execute_command( MobyCommand::Application.new( :Kill, self.executable_name, self.uid, self.sut, nil ) )

	  end

	  def track_popup(class_name, wait_time=1)
		wait_time = wait_time*1000
		fixture('popup', 'waitPopup',{:className => class_name, :interval => wait_time.to_s})
	  end

	  def verify_popup(class_name, time_out = 5)
		xml_source = nil
		verify(time_out) {xml_source = @sut.application.fixture('popup', 'printPopup',{:className => class_name})}  
		MobyBase::StateObject.new( xml_source )			  
	  end
	  
	  def bring_to_foreground
		@sut.execute_command(MobyCommand::Application.new(:BringToForeground, nil, self.uid, self.sut))
      end

	  # == description
	  # Taps the given objects at the same time (multitouch).
	  # 
      # == arguments
	  # objects
	  #  Array
	  #   description: Array of objects to tap.
	  #   example: @app.tap_objects([@app.Square( :name => 'topLeft' ), @app.Square( :name => 'topRight' )])
	  #
      # ArgumentError
      #  description: objects is not an array
      #    
	  def tap_objects(objects)
		raise ArgumentError.new("Nothing to tap") unless objects.kind_of?(Array)

		multitouch_operation{
		  objects.each { |o| o.tap }
		}
		
	  end

	  # == description
	  # Taps down the given objects at the same time (multitouch).
	  # 
      # == arguments
	  # objects
	  #  Array
	  #   description: Array of objects to tap down.
	  #   example: @app.tap_down_objects([@app.Square( :name => 'topLeft' ), @app.Square( :name => 'topRight' )])
	  #
      # ArgumentError
      #  description: objects is not an array
      #    
	  def tap_down_objects(objects)
		raise ArgumentError.new("Nothing to tap") unless objects.kind_of?(Array)

		multitouch_operation{
		  objects.each { |o| o.tap_down }
		}
		
	  end


	  # == description
	  # Taps up the given objects at the same time (multitouch).
	  # 
      # == arguments
	  # objects
	  #  Array
	  #   description: Array of objects to tap up.
	  #   example: @app.tap_up_objects([@app.Square( :name => 'topLeft' ), @app.Square( :name => 'topRight' )])
	  #
      # ArgumentError
      #  description: objects is not an array
      #    
	  def tap_up_objects(objects)
		raise ArgumentError.new("Nothing to tap") unless objects.kind_of?(Array)

		multitouch_operation{
		  objects.each { |o| o.tap_up }
		}
		
	  end

	  # == description
	  # Performs the given operations at the same time (when possible). 
	  # Note that only ui behaviours should be used here (e.g. taps, gestures).
	  # 
      # == arguments
	  # &block
	  #  Proc
	  #   description: code block containing the operations to perform.
	  #   example: @app.multi_touch{
	  #                @app.ScribbleArea.tap_object(400,50)
	  #                @app.ScribbleArea.gesture(:Right, 1, 50)
	  #                @app.ScribbleArea.gesture(:Up, 2, 150)
	  #                @app.ScribbleArea.gesture(:Left, 2, 150)
	  #                @app.ScribbleArea.gesture(:Down, 3, 200)
	  #                @app.ScribbleArea.pinch_zoom({:type => :in, :speed => 2, :distance_1 => 100, :distance_2 => 100, :direction => 0, :differential => 10,:x => 400, :y => 300})
	  #                @app.ScribbleArea.rotate({:type => :two_point, :radius => 100, :rotate_direction => :Clockwise, :distance => 360, :speed => 3, :direction => 180, :x => 100, :y => 100})
	  #                }	 
	  #
	  def multi_touch(&block)
		multitouch_operation(&block)
	  end

	  private
	  
	  def multitouch_operation(&block)

		#make sure the situation is ok before freeze
		self.force_refresh

		@sut.freeze
		
		#disable sleep to avoid unnecessary sleeping
		MobyUtil::Parameter[ @sut.id ][ :sleep_disabled] = 'true'

		command = MobyCommand::Group.new(0, self, block )
		command.set_multitouch(true)
		ret = @sut.execute_command( command )
		
		MobyUtil::Parameter[ @sut.id ][ :sleep_disabled] = 'false'

		#sleep the biggest stored value
		sleep MobyUtil::Parameter[ @sut.id ][ :skipped_sleep_time, 0 ] if MobyUtil::Parameter[ @sut.id ][ :skipped_sleep_time, 0 ] > 0
		
		#reset to 0
		MobyUtil::Parameter[ @sut.id ][ :skipped_sleep_time] = 0

		@sut.unfreeze
		
	  end
	  
	  # enable hooking for performance measurement & debug logging
	  MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


	end

  end

end
