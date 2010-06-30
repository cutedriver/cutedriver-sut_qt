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



# TODO: document 
module MobyBehaviour

	module QT

		module Events

			include MobyBehaviour::QT::Behaviour

			# Enables event listening on the target
			# == params
			# == returns
			# == raises
			# === examples
			#  @object.enable_events 
			def enable_events(filter_array = nil)

				begin
					command = plugin_command #in qt_behaviour 
					command.command_name( 'EnableEvents' )
					params_str = ''
					filter_array.each {|value| params_str << value << ','} if filter_array
					command.command_params( 'EventsToListen' => params_str)
					command.service( 'collectEvents' ) 
					@sut.execute_command( command)

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed enable_events with refresh \"#{filter_array.to_s}\".;#{ identity };enable_events;"
					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation enable_events executed successfully with refresh \"#{ filter_array.to_s }\".;#{ identity };enable_events;"
				nil
			end

			# Disables event listening on the target
			# == params
			# == returns
			# == raises
			# === examples
			#  @object.disable_events
			def disable_events()

				begin
					command = plugin_command #in qt_behaviour
					command.command_name( 'DisableEvents' )
					command.service( 'collectEvents' )
					@sut.execute_command( command)
				rescue Exception => e
					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed disable_events.;#{ identity };disable_events;"
					Kernel::raise e 
				end 

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation disable_events executed successfully.;#{ identity };disable_events;"
				nil
			end

			# Gets event list occured since the enabling of events
			# == params
			# == returns
			# testObject
			# == raises
			# === examples
			#  @object.get_events
			def get_events()
				ret = nil

				begin

					command = plugin_command(true) #in qt_behaviour 
					command.command_name( 'GetEvents' )
					command.service( 'collectEvents' )
					ret = @sut.execute_command( command)
					# TODO: how to parse the output?

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed get_events.;#{ identity };get_events;"
					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation get_events executed successfully.;#{ identity };get_events;"
				return ret
			end

			def start_recording

				begin

					command = plugin_command() #in qt_behaviour
					command.command_name( 'Start' )
					command.service( 'recordEvents' )
					@sut.execute_command( command)

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed start_recording.;#{ identity };start_recording;"
					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation start_recording executed successfully.;#{ identity };start_recording;"

				nil
			end

			def stop_recording

				begin

					command = plugin_command() #in qt_behaviour
					command.command_name( 'Stop' )
					command.service( 'recordEvents' )
					@sut.execute_command( command)

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed stop_recording.;#{ identity };stop_recording;"
					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation stop_recording executed successfully.;#{ identity };stop_recording;"

				nil

			end

			def print_recordings

				ret = nil

				begin

					command = plugin_command(true) #in qt_behaviour
					command.command_name( 'Print' )
					command.service( 'recordEvents' )
					ret = @sut.execute_command( command )

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed print_recordings.;#{ identity };print_recordings;"
					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation print_recordings executed successfully.;#{ identity };print_recordings;"

				return ret

			end

		end # EventsBehaviour

	end

end # MobyBase

MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Events )
