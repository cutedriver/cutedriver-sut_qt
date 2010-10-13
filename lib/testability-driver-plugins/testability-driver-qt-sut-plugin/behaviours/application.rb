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

module MobyBehaviour

  module QT

    # == description
    # Application specific behaviours
    #
    # == behaviour
    # QtApplication
    #
    # == requires
    #  sut_qt
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
    # Application
    #
	module Application

	  # == description
	  # Drag from the start coordinates to the end coordinates.
	  # 
      # == arguments
	  # start_x
	  #  Integer
	  #   description: Starting x coordinate
	  #   example: 10
	  #
      # == arguments
	  # start_y
	  #  Integer
	  #   description: Starting y coordinate
	  #   example: 10
	  #
      # == arguments
	  # end_x
	  #  Integer
	  #   description: End x coordinate
	  #   example: 30
	  #
      # == arguments
	  # end_y
	  #  Integer
	  #   description: End y coordinate
	  #   example: 100
	  #
	  # duration
	  #  Integer
	  #   description: How long will the drag take in millis
	  #   example: 1000
	  #
	  # == returns
	  # NilClass
	  #   description: -
	  #   example: -
	  #	  
	  def drag( start_x, start_y, end_x, end_y, duration = 1000 )

		@sut.execute_command( MobyCommand::Drag.new( start_x, start_y, end_x, end_y, duration ) )

	  end

	  # == description
	  # Kills the application process
	  # 
	  # == returns
	  # NilClass
	  #   description: -
	  #   example: -
	  #
	  def kill

		@sut.execute_command( MobyCommand::Application.new( :Kill, self.executable_name, self.uid, self.sut, nil ) )

	  end



	  # == description
	  # Start to track a popup that may appear on the screen. Tracking is done based on the class name of the 
	  # widget implementing popup functionality. Base class name can also be used in case framework level 
	  # popup base class is available. The idea of the detection is to track info notes that appear 
	  # on the screen for a moment and are therefore difficult to verify manually.
	  # 
      # == arguments
	  # class_name
	  #  String
	  #   description: Name of the popup implementation class. Base class name can also be used.
	  #   example: PopupClass
	  #
	  # wait_time
	  #  Integer
	  #   description: How long to wait for the popup to appear
	  #   example: 5
	  #
	  # == returns
	  # NilClass
	  #   description: -
	  #   example: -
	  #
	  def track_popup(class_name, wait_time=1)
		wait_time = wait_time*1000
		fixture('popup', 'waitPopup',{:className => class_name, :interval => wait_time.to_s})
	  end

	  # == description
	  # Verify was the popup on the screen or not. The method uses matti verify internally for the verification. 
	  # If the popup was shown then the entire application ui state is returned as a test object. 
	  # More detailed verification can be done for the object (e.g. the content of the popup, labels etc...).
	  # \n
	  # Note: If the popup does not close the verification will fail. Detection is based on grabbing the ui state just before the popup closes.
	  # 
      # == arguments
	  # class_name
	  #  String
	  #   description: Name of the popup implementation class. Base class name can also be used.
	  #   example: PopupClass
	  #
	  # time_out
	  #  Integer
	  #   description: Time in seconds for how long to wait for the popup data.
	  #   example: 5
	  #
	  # == returns
	  # TestObject
	  #   description: An ui state test object from the time the popup was detected. Can be used the same way as other test objects.
	  #   example: -
	  #
	  #
	  def verify_popup(class_name, time_out = 5)
		xml_source = nil
		verify(time_out) {xml_source = @sut.application.fixture('popup', 'printPopup',{:className => class_name})}  
		MobyBase::StateObject.new( xml_source )			  
	  end
	  
	  # == description
	  # Bring the application to foreground
	  # 
	  # == returns
	  # NilClass
	  #   description: -
	  #   example: -
	  #
	  #
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
	  #   example: [@app.Square( :name => 'topLeft' ), @app.Square( :name => 'topRight' )]
	  #
	  # == returns
	  # NilClass
	  #   description: -
	  #   example: -
	  #
	  # == exceptions
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
	  #   example: [@app.Square( :name => 'topLeft' ), @app.Square( :name => 'topRight' )]
	  #
	  # == returns
	  # NilClass
	  #   description: -
	  #   example: -
	  #
	  # == exceptions
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
	  #   example: [@app.Square( :name => 'topLeft' ), @app.Square( :name => 'topRight' )]
	  #
	  # == returns
	  # NilClass
	  #   description: -
	  #   example: -
	  #
	  # == exceptions
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
	  # Note that only ui behaviours can be used here (e.g. taps, gestures).
	  # 
      # == arguments
	  # &block
	  #  Proc
	  #   description: code block containing the operations to perform.
	  #   example: {@app.ScribbleArea.tap_object(400,50)
	  #             @app.ScribbleArea.gesture(:Right, 1, 50)}
	  # == returns
	  # NilClass
	  #   description: -
	  #   example: -
	  #
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
