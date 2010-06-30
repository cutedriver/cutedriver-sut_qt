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



#require File.expand_path( File.join( File.dirname( __FILE__ ), '../../../command/lib/fixture' ) )
#require File.expand_path( File.join( File.dirname( __FILE__ ), '../../../util/lib/logger' ) )
#require File.expand_path( File.join( File.dirname( __FILE__ ), 'qt_behaviour' ) )

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
		# === returns
		# nil
		# === errors
		# SignalNotEmittedException:: The given signal was n ot received before the timeout
        # ArgumentError:: signal_timeout was not a positive Integer or signal_name was not a nonempty String	
		def wait_for_signal( signal_timeout, signal_name )
		
			Kernel::raise ArgumentError.new("The timeout argument was of wrong type: expected 'Integer' was '%s'" % signal_timeout.class.to_s) unless signal_timeout.kind_of?( Integer )
			Kernel::raise ArgumentError.new("The timeout argument had a value of '%s', it must be a non negative Integer.'" % signal_timeout.to_s) unless signal_timeout >= 0
			
			Kernel::raise ArgumentError.new("The signal name argument was of wrong type: expected 'String' was '%s'" % signal_name.class.to_s) unless signal_name.kind_of?( String )
			Kernel::raise ArgumentError.new("The signal name argument must not be an empty String.") unless !signal_name.empty?
				  
			self.fixture('signal', 'enable_signal', {:signal => signal_name})
			
            timeout_deadline = Time.new + signal_timeout
			signal_found = false
						
			begin
			  
			  found_signals_xml = Nokogiri::XML.parse( self.fixture( 'signal', 'get_signal') )
			  if found_signals_xml.xpath('//object[@type="QtSignal" and @name="'+ signal_name +'"]').count > 0			    
			    signal_found = true
			  end
			
			end while Time.new < timeout_deadline && !signal_found
			
			self.fixture("signal", "remove_signals")
			
			Kernel::raise SignalNotEmittedException.new("The signal #{signal_name} was not emitted within #{signal_timeout} seconds.") unless signal_found
						
			return nil

		end # wait_for_signal
		
	end	# Synchronization

end # QT
end # MobyBehaviour
MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Synchronization )
