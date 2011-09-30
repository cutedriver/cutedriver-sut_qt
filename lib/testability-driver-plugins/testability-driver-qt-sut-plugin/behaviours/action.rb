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
		# This module contains behaviours specific to actions
		#
		# == behaviour
		# QtAction
		#
		# == requires
		# testability-driver-qt-sut-plugin
		#
		# == input_type
		# touch
		#
		# == sut_type
		# qt
		#
		# == sut_version
		# *
		#
		# == objects
		# QAction
		#
		module Action

			include MobyBehaviour::QT::Behaviour

			# == description
			# Hover over an action inside a visible widget.\n
			# \n
			# Hover is done by determining action's coordinates inside parent widget and moving mouse cursor there.
			# Therefore, the parent object in script must be a visible widget containing that action.
			# For example, a menu must be opened first, before actions inside the menu can be hovered.\n
                        # \n
			# [b]NOTE:[/b] Moving mouse cursor over action's position may not do anything,
			# unless test application window is topmost, or at least not obscured by other windows.
			# This can be a problem especially when testing desktop applications on Windows 7.\n
			# \n
			# [b]IMPORTANT:[/b] In future this method may be changed to call hover slot of QAction instead of using mouse, 
			# or deprecated and replace by a new method of different name better describing that this uses mouse.
			#
			# == arguments
			# refresh
			#  Boolean
			#   description: Determine is refresh done after trigger command
			#   example: true
			#   default: false
			#
			# == returns
			# NilClass
			#   description: -
			#   example: -
			#
			# == exceptions
			# Exception
			#   description: No special exceptions, may throw any exception
			def hover( refresh = false )
				begin

					command = command_params #in qt_behaviour
					command.object_type( :Action )
					command.command_name( 'Hover' )
					command.set_object_id( @parent.id )
					command.command_params( 'id' => id )

					@sut.execute_command( command )
					force_refresh(:id => get_application_id) if refresh

				rescue Exception => e

					$logger.behaviour "FAIL;Failed hover with refresh \"#{ refresh.to_s }\".;#{ identity };hover;"
					raise e

				end

				$logger.behaviour "PASS;Hover operation executed successfully with refresh \"#{ refresh.to_s }\".;#{ identity };hover;"
				nil
			end

			# == description
			# Activate action inside a visible widget.\n
			# \n
			# Trigger is done by determining action's coordinates inside parent widget, performing mouse press down and up there.
			# Therefore, the parent object in script must be a visible widget containing that action.
			# For example, a menu must be opened first, before actions inside the menu can be triggered.\n
			# \n
			# [b]IMPORTANT:[/b] In future this method may be changed to call trigger slot of QAction instead of using mouse,
			# or deprecated and replace by a differently named method better describing that this uses mouse.
			#
			# == arguments
			# refresh
			#  Boolean
			#   description: Determine is refresh done after trigger command
			#   example: true
			#   default: false
			#
			# == returns
			# NilClass
			#   description: -
			#   example: -
			# 
			# == exceptions
			# Exception
			#   description: No special exceptions, may throw any exception
			def trigger( refresh = false )

				begin
					command = command_params #in qt_behaviour
					command.object_type( :Action )
					command.command_name( 'Trigger' )
					command.set_object_id( @parent.id )
					command.command_params( 'id'=>id )

					@sut.execute_command( command )
					force_refresh(:id => get_application_id) if refresh

				rescue Exception => e

					$logger.behaviour "FAIL;Failed trigger with refresh \"#{ refresh.to_s }\".;#{ identity };trigger;"
					raise e

				end

				$logger.behaviour "PASS;Trigger operation executed successfully with refresh \"#{ refresh.to_s }\".;#{ identity };trigger;"
				nil
			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )


		end # Action

	end # QT

end # MobyBehaviour
