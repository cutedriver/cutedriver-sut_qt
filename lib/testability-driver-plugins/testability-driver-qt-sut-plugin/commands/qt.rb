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



#require File.expand_path( File.join( File.dirname( __FILE__ ), 'command_data' ) )

module MobyCommand


	class QT_Command < MobyCommand::CommandData

		#Application command types 
		#Touch object = :Press 
		#Hold object = :Hold 
		#Release object = :Relase  

		attr_accessor :arguments, :method

		# Constructs a new Touch CommandData object
		# == params
		# btn_id:: (optional) String, id for the button perform this command on
		# command_type:: (optional) Symbol, defines the command to perform on the button
		# == returns
		# Touch:: New CommandData object
		# == raises
		# ArgumentError:: When the supplied command_type is invalid.
		def initialize(command_type = nil, btn_id = nil)

			@@_valid_commands = [nil, :Press, :Hold, :Release,:Gesture, :Scroll, :Apicommand, :Tap, :Move, :ListStartedApps]
			@@_valid_directions = [nil, :Up, :Down, :Left,:Right]
			@@_valid_orientations = [nil,:Vertical, :Horizontal]

			command(command_type)    
			id(btn_id)
			
      self

		end


		# Defines the type of command this Touch CommandData object represents
		# == params
		# command_type:: Symbol, defines the command to perform on the application
		# == returns
		# Touch:: This CommandData object
		# == raises
		# ArgumentError:: When the supplied command_type is invalid.
		def command(command_type)

			raise ArgumentError.new("Given command type '#{command_type.to_s}' is not valid.") unless @@_valid_commands.include?( command_type )
			@_command = command_type
			self

		end  

		# Defines the id this Touch CommandData object is associated with
		# == params
		# btn_id:: String, id of button to perform this command on
		# == returns
		# Touch:: This CommandData object
		# == raises
		# ArgumentError:: When btn_id is not nil, integer or numeric string
		def id(btn_id)

			raise ArgumentError.new("The given object id must be nil, integer or a String.") unless btn_id == nil || btn_id.kind_of?(Integer) || (btn_id.kind_of?(String))

			@_id = btn_id.to_s
			self

		end    

		def get_delta
			@_delta
		end

		def delta(delta)
			@_delta = delta
		end

		def get_orientation
			@_orientation
		end

		def orientation(orientation)
			raise ArgumentError.new("Given orientation type '#{orientation.to_s}' is not valid.") unless @@_valid_orientations.include?(orientation)
			@_orientation = orientation
		end

		def distance(distance)
			@_distance = distance
		end

		def get_distance
			@_distance
		end

		def speed(speed)
			@_speed = speed
		end

		def get_speed
			@_speed
		end

		def direction(direction)
			raise ArgumentError.new("Given direction type '#{direction.to_s}' is not valid.") unless @@_valid_directions.include?(direction)
			@_direction = direction
		end

		def get_direction
			@_direction
		end  

		def get_command
			@_command
		end

		def object_type(type)
			@_object_type = type
		end

		def get_object_type
			return "" unless @_object_type 
			@_object_type 
		end

		def get_id
			@_id
		end 

		def set_coordinates(x, y)
			@_x = x
			@_y = y
		end

		def get_x
			@_x
		end

		def get_y
			@_y
		end

		def tab_count(tab_count)
			@_tab_count = tab_count
		end

		def get_tab_count
			@_tab_count
		end

	end #class

end #module
