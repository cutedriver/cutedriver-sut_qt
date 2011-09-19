# -*- coding: utf-8 -*-
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
      # 
      # Warning: Use with caution - function parameters must match exactly to the Qt slot. Otherwise
      #          behavior is undefined.
			# 
			# == arguments
			# method_name
			#  String
			#   description: name of method to invoke, including empty parenthesis
			#   example: "clear()"
      # *params
      #  Array
      #   description: Parameters for the method. Currently primitive types (String,Fixnum,Float, boolean) are supported. 
      #                Must match the parameters and types of the slot.
      #   example: 1.2, 'Hello'
			#
			# == returns
			# String
			#  description: returns slot return value, empty string if void.
      #  example: "1"
			#
			# == exceptions
			# RuntimeError
			#   description: invoking the method failed
			def call_method( method_name, *params )

				raise ArgumentError.new( "Method name was empty" ) if method_name.empty?
				command = command_params #in qt_behaviour      
				command.transitions_off     
				command.command_name( 'CallMethod' )

        # Syntactically terrible..
        pars = {'method_name' => method_name.to_s }

        params.each_with_index{ |param,i|
          case param
          when String
              key = "S"
          when Fixnum
              key = "I"
          when Float
              key = "D"
          when TrueClass,FalseClass
              key = "B"
          else
            raise ArgumentError.new( "Method parameter #{i}: Only String,Fixunum,Float and Boolean types are supported" ) 
          end
         pars["method_param#{i}"] = key+param.to_s
        }
				command.command_params(pars)
				command.service( 'objectManipulation' )

				returnValue = @sut.execute_command( command )
			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

		end
	end
end
