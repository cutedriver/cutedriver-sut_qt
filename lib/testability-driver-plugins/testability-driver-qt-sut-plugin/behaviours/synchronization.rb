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

    module Synchronization
  
      include MobyBehaviour::QT::Behaviour
        
      class SignalNotEmittedException < RuntimeError
    
      end
    
      # Execution of the test script is stopped and TDriver waits for the given signal. If no signals of the
      # given type are found before the timeout an error is raised.
      #
      # === params
      # signal_timeout:: Integer, time to wait for signal, in seconds
      # signal_name:: String, name of the signal to wait for. Note that most signals end with ()
      # block:: (optional) code block to be executed while listening signals
      # === returns
      # nil
      # === errors
      # SignalNotEmittedException:: The given signal was n ot received before the timeout
      # ArgumentError:: signal_timeout was not a positive Integer or signal_name was not a nonempty String  
      def wait_for_signal( signal_timeout, signal_name, &block )
    
        Kernel::raise ArgumentError.new("The timeout argument was of wrong type: expected 'Integer' was '%s'" % signal_timeout.class ) unless signal_timeout.kind_of?( Integer )

        Kernel::raise ArgumentError.new("The timeout argument had a value of '%s', it must be a non negative Integer.'" % signal_timeout ) unless signal_timeout >= 0
      
        Kernel::raise ArgumentError.new("The signal name argument was of wrong type: expected 'String' was '%s'" % signal_name.class ) unless signal_name.kind_of?( String )

        Kernel::raise ArgumentError.new("The signal name argument must not be an empty String.") unless !signal_name.empty?
            
        # enable signal listening 
        self.fixture( 'signal', 'enable_signal', :signal => signal_name )

        # execute code block if any given      
        block.call if block_given?

        timeout_deadline = ( Time.now + signal_timeout )
        
        signal_found = false
            
        while( Time.now < timeout_deadline && !signal_found )

          begin

            signals_xml = MobyUtil::XML.parse_string( self.fixture( 'signal', 'get_signal' ) )
      
            signal_found = ( signals_xml.xpath( '//object[@type="QtSignal" and @name="%s"]' % signal_name ).count > 0 )

          end # begin

        end # while
      
        # disable signal listening 
        self.fixture( "signal", "remove_signals" )
      
        Kernel::raise SignalNotEmittedException.new("The signal %s was not emitted within %s seconds." % [ signal_name, signal_timeout ] ) unless signal_found
            
        nil

      end # wait_for_signal
    
      # enable hooking for performance measurement & debug logging
      MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

    end  # Synchronization

  end # QT

end # MobyBehaviour
