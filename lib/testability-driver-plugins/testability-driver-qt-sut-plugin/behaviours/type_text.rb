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

		module TypeText

			include MobyBehaviour::QT::Behaviour

			# Write a string text on to a widget (e.g QLineEdit)
			# == params
			# text::String of text to be writte. 
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If the text is not a string.
			# === examples
			#  @object.type_text('Text to write')   
			def type_text( text )

				ret = nil

				begin
					command = command_params #in qt_behaviour           
					command.command_name('TypeText')
					command.command_value(text)
					@sut.execute_command(command)
					sleep 0.2

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed type_text with text \"#{text}\".;#{identity};type_text;"
					Kernel::raise e

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation type_text executed successfully with text \"#{text}\".;#{identity};type_text;"

				ret

			end

		end
	end
end

MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::TypeText )
