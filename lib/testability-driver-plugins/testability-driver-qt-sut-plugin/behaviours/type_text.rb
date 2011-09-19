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
    # TypeText specific behaviours
    #
    # == behaviour
    # QtTypeText
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
    # *
    #
		module TypeText

			include MobyBehaviour::QT::Behaviour

                        # == description
			# Write text on to a widget (e.g QLineEdit) as if it was typed by user
			# \n
			# == arguments
			# text
			#  String
			#   description: Text to type
			#   example: "abc"
			#
			# == returns
			# NilClass
			#   description: -
			#   example: -
			#
			# == exceptions
			# Exception
			#   description: No special exceptions, may throw any exception
			def type_text( text )
				ret = nil

				begin
					command = command_params #in qt_behaviour           
					command.command_name('TypeText')
					command.command_value(text)
					@sut.execute_command(command)
					sleep 0.2

				rescue Exception => e

					$logger.behaviour "FAIL;Failed type_text with text \"#{text}\".;#{identity};type_text;"
					raise e

				end      

				$logger.behaviour "PASS;Operation type_text executed successfully with text \"#{text}\".;#{identity};type_text;"

				ret

			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )


		end
	end
end
