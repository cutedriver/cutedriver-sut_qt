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

	module Behaviour

	  include MobyBehaviour::Behaviour

	  @@_valid_buttons = [ :NoButton, :Left, :Right, :Middle ]
	  @@_buttons_map = { :NoButton => '0', :Left => '1', :Right => '2', :Middle => '4' }
	  @@_valid_directions = [ :Up, :Down, :Left, :Right ]
	  @@_direction_map = { :Up => '0', :Down => '180', :Left => '270', :Right => '90' }
	  @@_pinch_directions = { :Horizontal => '90', :Vertical => '0'}
	  @@_rotate_direction = [ :Clockwise, :CounterClockwise ]

	  def command_params( command = MobyCommand::WidgetCommand.new )   
		
		if  self.attribute( 'objectType' ) == 'Graphics' and
            self.attribute( 'visibleOnScreen' ) == 'false' and
            self.creation_attributes[:visibleOnScreen] != 'false'
          begin
            self.creation_attributes.merge!({'visibleOnScreen' => 'true'})
			self.parent.child(self.creation_attributes)
          rescue
            Kernel::raise MobyBase::TestObjectNotVisibleError
          end
		end

		command.set_event_type(MobyUtil::Parameter[ @sut.id ][ :event_type, "0" ])

		#for components with object visible on screen but not actual widgets or graphicsitems
		if self.attribute( 'objectType' ) == 'Embedded'
		  command.application_id( get_application_id )
		  command.object_id( parent.id )
		  command.object_type( parent.attribute( 'objectType' ).intern )
		else
		  command.application_id( get_application_id )
		  command.object_id( self.id )
		  command.object_type( self.attribute( 'objectType' ).intern )
		end
		command
	  end

	  def plugin_command( require_response = false, command = MobyCommand::WidgetCommand.new )
		command.set_event_type(MobyUtil::Parameter[ @sut.id ][ :event_type, "0" ])
		command.application_id( get_application_id )
		command.object_id( self.id )
		command.object_type( self.attribute('objectType' ).intern)
		command.transitions_off    
		command
	  end

	  private   

	  def do_sleep(time)

		time = time.to_f
		time = time * 1.3
		#for flicks the duration of the gesture is short but animation (scroll etc..) may not
		#so wait at least one second
		time = 1 if time < 1	
		sleep time

	  end

	  def center_x

		#x = self.attribute( 'x_absolute' ).to_i
		#width = self.attribute( 'width' ).to_i
		#x = x + ( width/2 )
		#x.to_s

		( ( self.attribute( 'x_absolute' ).to_i ) + ( self.attribute( 'width' ).to_i / 2 ) ).to_s

	  end

	  def center_y
		#y = self.attribute( 'y_absolute' ).to_i
		#height = self.attribute( 'height' ).to_i
		#y = y + ( height/2 )
		#y.to_s

		( ( self.attribute( 'y_absolute' ).to_i ) + ( self.attribute( 'height' ).to_i / 2 ) ).to_s

	  end  

				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end

  end

end
