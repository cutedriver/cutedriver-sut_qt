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
    # Method specific behaviours
    #
    # == behaviour
    # QtMethod
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # *
    #
    # == sut_type
    # qt
    #
    # == sut_version
    # *
    #
    # == objects
    # *
    #
		module Method

			include MobyBehaviour::QT::Behaviour

			# == description
			# Calls an invokable method of the Qt test object.
			# Slots and signals are automatically invokable, but other methods must be explicitly made invokable.
			# This version does not support method arguments or return values.
			# 
			# == arguments
			# method_name
			#  String
			#   description: name of method to invoke, including empty parenthesis
			#   example: "clear()"
			#
			# == returns
			# Undefined
			#  description: on success, returns unspecified value of unspecified type
			#  example: "OK"
			#
			# == exceptions
			# RuntimeError
			#   description: invoking the method failed
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
