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

module MobyController

  module QT

    module WidgetCommand 

      include MobyController::Abstraction

      # generate service request
      def make_message

        # reduce AST calls
        _application_id = @_application_id
        _transitions = @_transitions
        _service = @_service

        _object_id = @_object_id
        _object_type = @_object_type
        _command_value = @_command_value

        # Object#not_nil return self if value not nil
        _command_params = { :eventType => @_event_type.not_nil('Assert: event_type must be set!'), :name => @_command_name }.merge!( @_command_params || {} )

        builder = Nokogiri::XML::Builder.new{

          TasCommands( :id => _application_id, :transitions => _transitions, :service => _service || 'uiCommand' ) {

            Target( :TasId => _object_id, :type => _object_type ) {

            if _command_value.kind_of?( Array )

              _command_value.each do | command_part | Command( command_part[ :value ], command_part[ :params ] ); end

            elsif _command_value

                Command( _command_value, _command_params )

            else

                Command( _command_params )

            end

            }
          }
        }              

      end

      # Execute the command). 
      # Sends the message to the device using the @sut_adapter (see base class)     
      # == params         
      # == returns
      # == raises
      # NotImplementedError: raised if unsupported command type       
      def execute

        message = make_message

        if @sut_adapter.group?

          @sut_adapter.append_command( message.doc.root.children )

        else

          @sut_adapter.send_service_request( Comms::MessageGenerator.generate( message.to_xml ) )

        end

      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # WidgetCommand 

  end # QT

end # MobyController
