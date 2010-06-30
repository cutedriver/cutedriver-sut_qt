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

		module Action

			include MobyBehaviour::QT::Behaviour

			# Hover over an action
			# ==raises
			# TestObjectNotFoundError:: If this application is not the foreground application on the device under test.    
			def hover( refresh = true )

				begin

					command = command_params #in qt_behaviour
					command.object_type( :Action )
					command.command_name( 'Hover' )
					command.object_id( @parent.id )
					command.command_params( 'id' => id )
					@sut.execute_command( command )
					self.force_refresh({:id => get_application_id}) if refresh   

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed hover with refresh \"#{ refresh.to_s }\".;#{ identity };hover;"
					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Hover operation executed successfully with refresh \"#{ refresh.to_s }\".;#{ identity };hover;"
				nil
			end

			# Trigger an action
			# ==raises
			# TestObjectNotFoundError:: If this application is not the foreground application on the device under test.    
			def trigger( refresh = true )

				begin
					command = command_params #in qt_behaviour
					command.object_type( :Action )
					command.command_name( 'Trigger' )
					command.object_id( @parent.id )
					command.command_params( 'id'=>id )

					@sut.execute_command( command )
					self.force_refresh({:id => get_application_id}) if refresh

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed trigger with refresh \"#{ refresh.to_s }\".;#{ identity };trigger;"
					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Trigger operation executed successfully with refresh \"#{ refresh.to_s }\".;#{ identity };trigger;"
				nil
			end

		end

	end

end

MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Action )
