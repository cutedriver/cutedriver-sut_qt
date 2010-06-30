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



module MobyCommand

	class WidgetCommand < MobyCommand::CommandData

		# Constructs a new CommandParams object. CommandParams stores the details for the commands send
		# to suts that operate using the tasCommand xml format. The controller creates an xml formatted 
		# operation request that will be forwarded to the sut being tested. 
		# Example:
		# Given params: command_name = MouseClick, params = [button => '1']
		# xml command: <Command name="MouseClick" button="1">
		#
		# == params
		# command_name:: Name of the command to be executed on the device (e.g. MouseClick)
		# params:: A Hash containing the parameters sent to the device as name/value pairs (e.g. button => 1)
		# == returns
		# CommandParams:: New CommandParams object
		# == raises
		# ArgumentError:: When the supplied params are invalid type (initially can be nil)  
		def initialize(application_id = nil, object_id = nil, object_type = nil, command_name = nil, params = nil, value=nil, service = nil)

			@@_valid_types = [ nil, :Standard, :Graphics, :Application, :Action, :Web ]

			self.application_id(application_id )
			self.object_id( object_id )
			self.object_type( object_type )
			self.command_name( command_name )    
			self.command_params( params )
			self.command_value( value )
			self.service( service )
	
			@_transitions = true

			return self

		end

		def service(service)
			@_service = service
		end

		def get_service
			@_service
		end

		# Set transition flag on
		# Will cause the events to be 
		# done on a delayed mode.
		def transitions_on
			@_transitions = true
		end

		# Set transition flag off
		# Will cause the events to be 
		# done on immediately
		def transitions_off
			@_transitions = false
		end

		# Return the transition value  
		# ==returns
		# bool: true of false  
		def get_transitions
			@_transitions    
		end


		# Set true if response is expected from device side after command
		# Has been completed.
		# ==params
		# bool: True if response needed
		def set_require_response(response_required)
			@_response_required = response_required
		end

		# Returns true if response required after command.
		def require_response?
			@_response_required 
		end

		# Application id of the currently tested application
		# == params
		# id:: Id of the application 
		# == returns  
		# == raises
		# ArgumentError:: When the supplied id is not of type String   
		def application_id(id)
			raise ArgumentError.new( "Application id must be a string." ) unless id == nil or id.kind_of?( String )
			@_application_id = id
		end

		# Return application id
		# == params  
		# == returns
		# String:: Application id of the command 
		def get_application_id
			@_application_id
		end

		# Object id of the target object
		# == params
		# id:: Id of the Object 
		# == returns  
		# == raises
		# ArgumentError:: When the supplied id is not of type String   
		def object_id(id)
			raise ArgumentError.new( "Object id must be a string." ) unless id == nil or id.kind_of?( String )
			@_object_id = id
		end

		# Return object id
		# == params  
		# == returns
		# String:: Object id of the command 
		def get_object_id
			@_object_id
		end

		# Object type of the target object
		# == params
		# type:: type of the Object 
		# == returns  
		# == raises
		# ArgumentError:: When the supplied type is not :Graphics or :Standard   
		def object_type(type)
			raise ArgumentError.new("Given object type '#{type.to_s}' is not valid.") unless @@_valid_types.include?(type)
			@_object_type = type
		end

		# Return object type
		# == params  
		# == returns
		# String:: Object type of the command 
		def get_object_type
			@_object_type
		end  

		# Name of the command
		# == params
		# name:: Name of the command to be executed on the device (e.g. MouseClick)
		# == returns  
		# == raises
		# ArgumentError:: When the supplied command_name is not of type String  
		def command_name(name)
			raise ArgumentError.new( "Command name must be a String." ) unless name == nil or name.kind_of?( String )
			@_command_name = name  
		end

		# Return name of the command
		# == params  
		# == returns
		# String:: Name of the command 
		def get_command_name
			@_command_name
		end

		# Command parameters
		# == params
		# params:: A Hash containing the parameters sent to the device as name/value pairs (e.g. button => 1)
		# == returns  
		# == raises
		# ArgumentError:: When the supplied params is of type Hash   
		def command_params(params)
			raise ArgumentError.new( "The given params must be in a hash (name => value)." ) unless params == nil or params.kind_of?( Hash )
			@_command_params = params
		end

		# Return params of the command
		# == params  
		# == returns
		# Hash:: Command parameter hash 
		def get_command_params
			@_command_params
		end

		# Command value which is passed on to the device as the value of the command.
		# Example: <Command name=TypeText>Text to be written</Command> where the 
		# "Text to be written" would be the value String passed as parameter to this method.
		# == params
		# value:: A String that will be passed to the device in the value field in the command xml, or an Array containing data for multiple step commands
		# == returns  
		# == raises
		# ArgumentError:: When the supplied params not of type String or Array or nil
		def command_value(value)
			raise ArgumentError.new( "Command value must be a string." ) unless value == nil or value.kind_of?( String ) or value.kind_of? Array
			@_command_value = value
		end

		# Return command value
		# == params  
		# == returns
		# tring or Array:: Command value  
		def get_command_value
			@_command_value
		end

	end
end
