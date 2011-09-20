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
    # KeyPress specific behaviours
    #
    # == behaviour
    # QtKeyPress
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
		module KeyPress

			include MobyBehaviour::QT::Behaviour

			# == description
			# Perform key press event or a series of events on an object.
			# 
			# == arguments
			# key
			#  Symbol
			#   description: Symbol of key
			#   example: :kRight
			#  Integer
			#   description: Scan code of key
			#   example: 	0x01000001
			#  MobyCommand::KeySequence
			#   description: Sequence of key and press types, see [link="#GenericSut:press_key"]KeySequence reference[/link].
			#   example: MobyCommand::KeySequence.new( :kTab, :KeyDown )
			#
			# == returns
			# NilClass
			#  description: nil
			#  example: nil
			#
			# == exceptions
			# ArgumentError
			#  description: Wrong argument type %s for key (Expected: %s)
			# ArgumentError
			#  description: Scan code for :%s not defined in keymap
			# ArgumentError
			#  description: Error occured during keypress (Response: %s)
			def press_key( key )

				key_sequence = nil

				begin

					command = command_params

					command.command_name('KeyPress')

					command.set_require_response( true )

					#raise ArgumentError.new( "Wrong argument type %s for key (Expected: %s)" % [ key.class, "Symbol/Fixnum/KeySequence" ] ) unless [ Fixnum, Symbol, MobyCommand::KeySequence ].include?( key.class )  

					# raise exception if value type other than Fixnum or Symbol
          key.check_type [ Fixnum, Symbol, MobyCommand::KeySequence ], 'wrong argument type $1 for key (expected $2)'

					# verify that keymap is defined for sut if symbol used. 
					raise ArgumentError, "Symbol #{ key.inspect } cannot be used due to no keymap defined for #{ @sut.id } in TDriver configuration file." if key.kind_of?( Symbol ) && sut_parameters.has_key?( :keymap ) == false

					if key.kind_of?( Symbol )

					  scancode = TDriver::KeymapUtilities.fetch_keycode( key, sut_parameters[ :keymap ] )

            # convert hexadecimal (string) to fixnum
					  scancode = scancode.hex if scancode.kind_of?( String )

					  # raise exception if value is other than fixnum
					  raise ArgumentError, "Scan code for :#{ key } not defined in keymap" unless scancode.kind_of?( Fixnum )

					  # add scancode for keypress event
					  command.command_value( scancode.to_s )

					elsif key.kind_of?( MobyCommand::KeySequence )
					
					  key_sequence = []

					  key.get_sequence.each do | key_event |
					        
					    #tempcode = sut_parameters[ :keymap ][ key_event[ :value ], nil ]

  					  tempcode = TDriver::KeymapUtilities.fetch_keycode( key_event[ :value ], sut_parameters[ :keymap ] )

					    tempcode = tempcode.hex if tempcode.kind_of?( String )
						
					    press_type = { :KeyDown => 'KeyPress', :KeyUp => 'KeyRelease' }.fetch( key_event[ :type ] ){ "KeyClick" }

					    key_sequence << { :value => tempcode, :params => { :name => press_type, :modifiers => "0", :delay => "0" } }
												
					  end					  

					  command.command_value( key_sequence )

					else

            scancode = key.to_i
					
					  # raise exception if value is other than fixnum
					  raise ArgumentError.new( "Scan code for :%s not defined in keymap" % key ) unless scancode.kind_of?( Fixnum )

					  # add scancode for keypress event
					  command.command_value( scancode.to_s )

					end	

					# execute command & verify that execution passed ("OK" expected as response) 
					@sut.execute_command(command)

					#raise RuntimeError.new("Error occured during keypress (Response: %s)" % @response ) unless ( @response = @sut.execute_command(command) ) == "OK" 

				rescue #Exception

					$logger.behaviour "FAIL;Failed press_key with key \"#{ key }\".;#{ identity };press_key;"

					raise $!

				end

				$logger.behaviour "PASS;Operation press_key executed successfully with key \"#{ key }\".;#{ identity };press_key;"

				nil
			
			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

		end

	end
end
