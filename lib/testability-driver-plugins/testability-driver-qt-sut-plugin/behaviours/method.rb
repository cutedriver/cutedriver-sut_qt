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

		module Method

			include MobyBehaviour::QT::Behaviour

			# == params
			# attribute:: string attribute name to set 
			# == returns  
			# nil
			# == raises
			# RuntimeError::
			# === examples
			#  @sut.application.call_method('close()') #calls close for application 
			def call_method( method_name )

				Kernel::raise ArgumentError.new( "Method name was empty" ) if method_name.empty?
				command = command_params #in qt_behaviour      
				command.transitions_off     
				command.command_name( 'CallMethod' )
				command.command_params( 'method_name' => method_name.to_s )
				command.service( 'objectManipulation' )
				returnValue = @sut.execute_command( command )
				Kernel::raise RuntimeError.new( "Calling method '%s' failed with error: %s" % [ method_name, returnValue ] ) if ( returnValue != "OK" )
			end

			# enable hooking for performance measurement & debug logging
			MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

		end
	end
end
