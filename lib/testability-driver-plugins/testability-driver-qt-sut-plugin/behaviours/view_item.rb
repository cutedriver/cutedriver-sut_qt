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

		module ViewItem

			include MobyBehaviour::QT::Behaviour

			# Selects an item from a list that uses qt view model system (e.g. QTreeView)
			# == params
			# == returns  
			# == raises
			def select    

				ret = nil

				begin    

					button=:Left
					command = MobyCommand::WidgetCommand.new
					command.object_id(self.attribute('viewPort'))
					command.application_id(get_application_id)    
				    command.object_type(:Standard)                          
					command.command_name('Tap')    

					mouse_move = @sut.parameter(:in_tap_move_pointer) 
					mouse_move = 'false' unless mouse_move

					params = {'x'=>center_x, 'y' => center_y, 'count' => 1, 'button' => @@_buttons_map[button], 'mouseMove'=>mouse_move, 'useCoordinates' => 'true'}      

					command.command_params(params)
					@sut.execute_command(command)

				rescue Exception => e      

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed select"#{identity};drag;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation select executed successfully"#{identity};drag;"
				ret

			end

			# enable hooking for performance measurement & debug logging
			MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


		end
	end
end
