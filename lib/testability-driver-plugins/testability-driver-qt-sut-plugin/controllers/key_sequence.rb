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

		module KeySequence

			def set_adapter( adapter )

				@sut_adapter = adapter

			end

			# Execute the command(s). Iterated trough the @message_array and sends all
			# message to the device using the @sut_adapter (see base class)     
			# == params      
			# == returns
			# == raises
			# RuntimeError: No service request to be sent due to key sequence is empty
			def execute

				@sut_adapter.send_service_request( 

          Comms::MessageGenerator.generate( make_message ) 

        )

			end

			private
			#
			# Internal message generation method. Makes xml messages from the command_data     
			# == params      
			# none
			def make_message

				press_types = { :KeyDown => 'KeyPress', :KeyUp => 'KeyRelease' }

				sut = @_sut

				sequence = @sequence

				message = Nokogiri::XML::Builder.new{

					TasCommands( :id => sut.application.id, :transitions => 'true', :service => 'uiCommand' ){

						Target( :TasId => 'FOCUSWIDGET', :type => 'Standard' ){

							sequence.each{ | key_press |

								key_press[ :value ].tap{ | key |

									# raise exception if value type other than Fixnum or Symbol
									Kernel::raise ArgumentError.new( "Wrong argument type %s for key (Expected: %s)" % [ key.class, "Symbol/Fixnum" ] ) unless [ Fixnum, Symbol ].include?( key.class ) 

									# verify that keymap is defined for sut if symbol used. 
									Kernel::raise ArgumentError.new("Symbol #{ key.inspect } cannot be used due to no keymap defined for #{ sut.id } in TDriver configuration file.") if key.kind_of?( Symbol ) && $parameters[ sut.id ][ :keymap ].nil?

                  # fetch keycode from keymap
      					  key = TDriver::KeymapUtilities.fetch_keycode( key, $parameters[ sut.id ][ :keymap ] )

									# retrieve corresponding scan code (type of string, convert to fixnum) for symbol from keymap if available 
									key = key.hex if key.kind_of?( String )

									# raise exception if value is other than fixnum
									Kernel::raise ArgumentError.new( "Scan code for :%s not defined in keymap" % key ) unless key.kind_of?( Fixnum )
		
									# determine keypress type
									press_type = press_types.fetch( key_press[ :type ], 'KeyClick' )

									Command( key.to_s, "name" => press_type.to_s, "modifiers" => "0", "delay" => "0")

								}

							}

						}
					}
				}.to_xml

				message

			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

		end # KeySequence

	end # QT

end # MobyController
