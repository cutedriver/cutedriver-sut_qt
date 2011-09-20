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
    # Record specific behaviours
    #
    # == behaviour
    # QtRecord
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # *
    #
    # == sut_type
    # QT
    #
    # == sut_version
    # *
    #
    # == objects
    # application
    #
		module Record

			include MobyBehaviour::QT::Behaviour

      # == nodoc
      # == returns
      # NilClass
      #  description: -
      #  example: -
			def start_recording

				begin

					command = plugin_command() #in qt_behaviour
					command.command_name( 'Start' )
					command.service( 'recordEvents' )
					@sut.execute_command( command)

				rescue Exception => e

					$logger.behaviour "FAIL;Failed start_recording.;#{ identity };start_recording;"
					raise e

				end

				$logger.behaviour "PASS;Operation start_recording executed successfully.;#{ identity };start_recording;"

				nil
			end

      # == nodoc
      # == returns
      # NilClass
      #  description: -
      #  example: -
			def stop_recording

				begin

					command = plugin_command() #in qt_behaviour
					command.command_name( 'Stop' )
					command.service( 'recordEvents' )
					@sut.execute_command( command)

				rescue Exception => e

					$logger.behaviour "FAIL;Failed stop_recording.;#{ identity };stop_recording;"
					raise e

				end

				$logger.behaviour "PASS;Operation stop_recording executed successfully.;#{ identity };stop_recording;"

				nil

			end

      # == nodoc
			def print_recordings

				ret = nil

				begin

					command = plugin_command(true) #in qt_behaviour
					command.command_name( 'Print' )
					command.service( 'recordEvents' )
					ret = @sut.execute_command( command )

				rescue Exception => e

					$logger.behaviour "FAIL;Failed print_recordings.;#{ identity };print_recordings;"
					raise e

				end

				$logger.behaviour "PASS;Operation print_recordings executed successfully.;#{ identity };print_recordings;"

				return ret

			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

		end # Record

	end

end # MobyBase
