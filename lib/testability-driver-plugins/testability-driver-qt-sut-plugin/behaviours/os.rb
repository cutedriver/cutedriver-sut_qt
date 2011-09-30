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
    # OS specific behaviours
    #
    # == behaviour
    # QtOs
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
    # sut
    #
		module Os

			include MobyBehaviour::QT::Behaviour

			# This method is now deprecated as the latest version of QTTas server never loards PlatformService
			# Select and open a file from an active open file dialog
			# == params
			# == returns  
			# == raises
			# def open_file(path, dialog_name, button)
      # begin
      # command = command_params #in qt_behaviour           
      # command.command_name('OpenFile')
      # command.command_params('dialogName' => dialog_name, 'filePath' => path, 'dialogButton' => button)
      # command.service('platformOperation')
      ##open file is done without ui state update so wait for the dialog to open
      # sleep 0.2
      # @sut.execute_command(command)
      # force_refresh
      # rescue Exception => e
      # $logger.behaviour "FAIL;Failed open_file with path \"#{path}\", dialog_name \"#{dialog_name}\", button \"#{button.to_s}\".;#{identity};open_file;"
      # raise e
      # end
      # $logger.behaviour "PASS;Operation file executed successfully with path \"#{path}\", dialog_name \"#{dialog_name}\", button \"#{button.to_s}\".;#{identity};open_file;"
      # nil
      # end			
			# Press Enter on the keyboard. Useful to accept crash warnings on windows
			# == params
			# == returns  
			# == raises

      # == deprecated
      # 0.x.x
      # == description
			# This method is now deprecated as recent version of Agent Qt server never loads PlatformService      
			def press_enter(interval = nil)
				begin   				  
				  if interval
					interval = (interval*1000).to_i
					params = {:interval => interval}
				  end
				  execute_command( MobyCommand::WidgetCommand.new( nil, nil, nil, 'PressEnter', params, nil, 'uiCommand') )
				rescue Exception => e
					$logger.behaviour "FAIL;Failed to send an Enter keystroke request to the qttas server;press_enter;"
					raise e
				end
					$logger.behaviour "PASS;Successfuly sent an Enter keystroke request to the qttas server;press_enter;"
				nil
			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
			
		end
	end
end
