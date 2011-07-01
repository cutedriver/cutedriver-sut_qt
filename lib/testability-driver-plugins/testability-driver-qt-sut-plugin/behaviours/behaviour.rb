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
    # Base behaviour 
    #
    # == behaviour
    # QtBehaviour
    #
    # == requires
    #  sut_qt
    #
    # == sut_type
    # qt
    #
    # == input_type
    # All
    #
    # == sut_version
    # *
    #
    # == objects
    # sut;application
    #
    module Behaviour

      include MobyBehaviour::Behaviour

      @@_valid_buttons = [ :NoButton, :Left, :Right, :Middle ]
      @@_buttons_map = { :NoButton => '0', :Left => '1', :Right => '2', :Middle => '4' }
      @@_valid_directions = [ :Up, :Down, :Left, :Right ]
      @@_direction_map = { :Up => '0', :Down => '180', :Left => '270', :Right => '90' }
      @@_pinch_directions = { :Horizontal => '90', :Vertical => '0'}
      @@_rotate_direction = [ :Clockwise, :CounterClockwise ]
      @@_events_enabled = false

      # == nodoc
      # should this method be private?
      def command_params( command = MobyCommand::WidgetCommand.new )   

        if attribute( 'objectType' ) == 'Graphics' and attribute( 'visibleOnScreen' ) == 'false' and @creation_attributes[ :visibleOnScreen ] != 'false'

          begin

            #try to make the item visible if so wanted
            fixture( 'qt', 'ensureVisible'   ) if sut_parameters[ :ensure_visible,     false ].true?
            fixture( 'qt', 'ensureQmlVisible') if sut_parameters[ :ensure_qml_visible, false ].true?
            
            @creation_attributes.merge!( 'visibleOnScreen' => 'true' )

            @parent.child( @creation_attributes )

          rescue

            raise MobyBase::TestObjectNotVisibleError

          end

        end

        _object_type = attribute( 'objectType' ).intern

        #for components with object visible on screen but not actual widgets or graphicsitems
        if _object_type == :Embedded

          _object_type = @parent.attribute( 'objectType' ).intern

          _object_id = @parent.id

        else

          _object_id = @id

        end

        command.application_id( get_application_id )

        command.set_object_id( _object_id )

        command.object_type( _object_type )

        command.set_event_type( sut_parameters[ :event_type, "0" ] )

        # set app id as vkb if the attribute exists as the command needs to go to the vkb app
        begin

          # raises exception if value not found
          value = attribute( 'vkb_app_id' )

          command.application_id( value )

        rescue MobyBase::AttributeNotFoundError

        end    

        command

      end

    private   

      # == nodoc
      # should this method be private?
      def plugin_command( require_response = false, command = MobyCommand::WidgetCommand.new )
        command.set_event_type(sut_parameters[ :event_type, "0" ])
        command.application_id( get_application_id )
        command.set_object_id( @id )
        command.object_type( attribute('objectType' ).intern)
        command.transitions_off    
        command
      end

      # TODO: document me
      def do_sleep(time)

        time = time.to_f * 1.3

        #for flicks the duration of the gesture is short but animation (scroll etc..) may not
        #so wait at least one second
        time = 1 if time < 1  
        sleep time

      end

      # TODO: document me
      def center_x

        #x = attribute( 'x_absolute' ).to_i
        #width = attribute( 'width' ).to_i
        #x = x + ( width/2 )
        #x.to_s

        ( ( attribute( 'x_absolute' ).to_i ) + ( attribute( 'width' ).to_i / 2 ) ).to_s

      end

      # TODO: document me
      def center_y

        #y = attribute( 'y_absolute' ).to_i
        #height = attribute( 'height' ).to_i
        #y = y + ( height/2 )
        #y.to_s

        ( ( attribute( 'y_absolute' ).to_i ) + ( attribute( 'height' ).to_i / 2 ) ).to_s

      end  

      # TODO: document me
      def param_set_configured?( params, key )

        if params.kind_of?(Hash) && params.has_key?(key)

          #( params[ key ].nil? ? sut_parameters[ key, 'false' ] : params[ key ].to_s ).to_s == "true"

          ( params[ key ] || sut_parameters[ key, false ] ).true?

        else

          #sut_parameters[ key, 'false' ].true?

          sut_parameters[ key, false ].true?

        end
      end

      # TODO: document me
      def execute_behavior( params, command )

        if !get_application.multitouch_ongoing? && !@@_events_enabled && param_set_configured?( params, :ensure_event ) 

          ensure_event(:retry_timeout => 5, :retry_interval => 0.5) {

            @sut.execute_command( command )

          }

        else

          @sut.execute_command( command )

        end

      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end

  end

end

