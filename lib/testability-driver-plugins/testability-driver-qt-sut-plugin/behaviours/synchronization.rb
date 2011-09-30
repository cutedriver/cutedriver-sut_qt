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
    # Synchronization specific behaviours
    #
    # == behaviour
    # QtSynchronization
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # touch
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
    module Synchronization
  
      include MobyBehaviour::QT::Behaviour
        
      class SignalNotEmittedException < RuntimeError
    
      end

      class EventNotReceivedException < RuntimeError

      end
    
      class EventsEnabledException < RuntimeError
      end

      # == description
      # Synchronizes script execution to a signal. Test script execution is stopped until the expected signal is emitted or the timeout occurs. 
      # If no signals of the given type are found before the timeout an error is raised.\n
      # \n
      # [b]NOTE:[/b] Using wait_for_signal will reset and clear any previously set signal listening status.
      # == arguments
      # signal_timeout
      #  Fixnum
      #    description: Timeout, in seconds. A timeout of zero means that the signal must have been listened to and emitted before this method is called.
      #    example: 60
      #
      # signal_name
      #  String
      #   description: Name of the signal that is to be emitted.
      #   example: "clicked()"
      # 
      # params
      #  Hash 
      #   description: Optional parameters for wait for signal
      #   example: "{:retry_timeout => 10, :retry_interval => 0.1}"
      # &block
      #  Proc
      #   description: Optional code block to be executed while listening signals
      #   example: -
      #
      # == returns
      # NilClass
      #  description: -
      #  example: -
      #
      # == exceptions
      # SignalNotEmittedException
      #  description: The expected signal was not emitted before the timeout was reached.
      #
      # ArgumentError
      #  description: signal_name was not a valid String or signal_timeout was not a non negative Integer
      #
      def wait_for_signal( signal_timeout, signal_name, params = nil, &block )
    
        signal_timeout.check_type Integer, 'wrong argument type $1 for signal timeout (expected $2)'
        #raise ArgumentError.new("The timeout argument was of wrong type: expected 'Integer' was '%s'" % signal_timeout.class ) unless signal_timeout.kind_of?( Integer )
    
        signal_timeout.not_negative 'signal timeout value $1 cannot be negative'
        #raise ArgumentError.new("The timeout argument had a value of '%s', it must be a non negative Integer.'" % signal_timeout ) unless signal_timeout >= 0

      
        signal_name.check_type String, 'wrong argument type $1 for signal name (expected $2)'
        #raise ArgumentError.new("The signal name argument was of wrong type: expected 'String' was '%s'" % signal_name.class ) unless signal_name.kind_of?( String )
      
        signal_name.not_empty 'signal name cannot be empty'
        #raise ArgumentError.new("The signal name argument must not be an empty String.") unless !signal_name.empty?

        params.check_type [ Hash, NilClass ], 'wrong argument type $1 for signal parameters (expected $2)'

        # enable signal listening 
        fixture( 'signal', 'enable_signal', :signal => signal_name )

        # execute code block if any given     
        begin

          if params.kind_of?( Hash ) && params.has_key?( :retry_timeout )

            MobyUtil::Retryable.until( :timeout => params[:retry_timeout], :interval => params[:retry_interval], :exception => SignalNotEmittedException) {

              do_wait_signal(signal_timeout, signal_name, &block)

            } 

          else
          
            do_wait_signal(signal_timeout, signal_name, &block)
            
          end
            
        ensure

          begin
            fixture( "signal", "remove_signals" )
          rescue Exception => e  
            $logger.warning "Fixture removal failed. Message received: #{e.message}"
          end

        end

        nil

      end # wait_for_signal

      # == description
      # Ensure that an event is fired into the target element
      #
      # [b]NOTE:[/b] Limitations: 
      #  enable_events can not be enabled. multitouch operations are not supported.
      #
      # == arguments
      # params
      #  Hash
      #    description: Arguments hash, see below
      #    example: Optional paramaters, see table params below.
      #   
      #
      # &block
      #  Proc
      #   description: Code block that triggers the event
      #   example: @app.Button.tap
      #
      # == tables
      # params
      #  title: Hash argument params
      #  description: Valid keys for argument tap_params as hash
      #  |Key|Description|Type|Example|Default|
      #  |:retry_interval|Time between retries if the event is not received|Float|2|1|
      #  |:retry_timeout|Timeout for retry cycle|Integer|5|30|
      #  |:sleep_time|Sleep time before fetching events from client|Foat|0.4|0.2|
      #
      # == returns
      # NilClass
      #  description: -
      #  example: -
      #
      # == exceptions
      # EventsEnabledException
      #  description: enable_events is enabled. Event monitoring can not be enabled at the same time
      # 
      # EventNotReceivedException
      #  description: Target object did not received any events defined 
      #
      def ensure_event(params = nil, &block)
      
        raise EventsEnabledException.new("enable_events is used - ensure_events can not be Used at the same time.") if @@_events_enabled
        raise ArgumentError.new("Must be called to TestObject" ) unless kind_of? MobyBase::TestObject

        retry_timeout = (params.nil? || params[:retry_timeout].nil?) ? 30 : params[:retry_timeout]
        retry_interval = (params.nil? || params[:retry_interval].nil?) ? 1 : params[:retry_interval]
        sleep_time = (params.nil? || params[:sleep_time].nil?) ? 0.2 : params[:sleep_time]

        events = ['MouseButtonPress,TouchBegin,GraphicsSceneMousePress,KeyPress']
        if params && params[:events]
          events = params[:events]
        end
        app = get_application        
        begin
          app.enable_events(events, {"track_id" => id.to_s})

          MobyUtil::Retryable.until(:timeout => retry_timeout,:interval => retry_interval, :exception => EventNotReceivedException) {
            block.call if block_given?
            sleep sleep_time
            ev = app.get_events
            begin
              @sut.state_object(ev).events.attribute('trackedFound')
            rescue MobyBase::AttributeNotFoundError
              $stderr.puts "Warning: Operation not received by object #{id} : #{self.name}. Retrying"
              raise EventNotReceivedException.new("No event received during call") 
            end
          }
        ensure
          app.disable_events
        end
      end

    private
    
      def do_wait_signal(signal_timeout, signal_name, &block)

        timeout_deadline = ( Time.now + signal_timeout )
        
        signal_found = false
        
        block.call if block_given?
        
        while( Time.now < timeout_deadline && !signal_found )

          begin
            
            result = fixture( 'signal', 'get_signal' )
            
            signals_xml = MobyUtil::XML.parse_string( result )
            
            _signal_found_xml, unused_rule = @test_object_adapter.get_objects( signals_xml, { :type => 'QtSignal', :name => signal_name }, true )

            signal_found = true unless _signal_found_xml.empty? 
            
          end # begin
          
        end # while

        raise SignalNotEmittedException, "The signal #{ signal_name } was not emitted within #{ signal_timeout } seconds." unless signal_found

      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end  # Synchronization

  end # QT

end # MobyBehaviour
