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

      include MobyController::Abstraction

      # Creates service command message which will be sent to @sut_adapter by execute method
      # == params         
      # == returns
      # == raises
      def make_message

        press_types = { :KeyDown => 'KeyPress', :KeyUp => 'KeyRelease' }

        sut = @_sut

        keymap = $parameters[ sut.id ][ :keymap ]

        sequence = @sequence
        
        message = Nokogiri::XML::Builder.new{

          TasCommands( :id => sut.application.id, :transitions => 'true', :service => 'uiCommand' ){

            Target( :TasId => 'FOCUSWIDGET', :type => 'Standard' ){

              sequence.each{ | key_press |

                key_press[ :value ].tap{ | key |

                  # raise exception if value type other than Fixnum or Symbol
                  raise ArgumentError, "Wrong argument type #{ key.class } for key (expected: Symbol or Fixnum)" unless [ Fixnum, Symbol ].include?( key.class ) 

                  # verify that keymap is defined for sut if symbol used. 
                  raise ArgumentError, "Symbol #{ key.inspect } cannot be used due to no keymap defined for #{ sut.id } in TDriver configuration file." if key.kind_of?( Symbol ) && keymap.nil?

                  # fetch keycode from keymap
                  key = TDriver::KeymapUtilities.fetch_keycode( key, keymap )

                  # retrieve corresponding scan code (type of string, convert to fixnum) for symbol from keymap if available 
                  key = key.hex if key.kind_of?( String )

                  # raise exception if value is other than fixnum
                  raise ArgumentError, "Scan code for #{ key.inspect } not defined in keymap" unless key.kind_of?( Fixnum )
    
                  # determine keypress type
                  press_type = press_types.fetch( key_press[ :type ], 'KeyClick' )

                  Command( key.to_s, "name" => press_type.to_s, "modifiers" => "0", "delay" => "0")

                }

              }

            }
            
          }
          
        }.to_xml

        Comms::MessageGenerator.generate( message )

      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # KeySequence

  end # QT

end # MobyController
