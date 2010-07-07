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

		module InfoLoggerCommand

			# Execute the command
			# Sends the message to the device using the @sut_adapter (see base class)     
			# == params         
			# == returns
			# == raises
			# NotImplementedError: raised if unsupported command type       
			def execute

				@sut_adapter.send_service_request(
					Comms::MessageGenerator.generate(
						Nokogiri::XML::Builder.new{
							TasCommands( :service => "infoService", :id=> application_id, :interval => params[:interval] ) {
								Target( :TasId => "Application" ) {
									Command( value || "", ( params || {} ).merge( :name => name ) )
								}
							}
						}.to_xml
					)
				)

			end

			def set_adapter( adapter )

				@sut_adapter = adapter

			end

			# enable hooking for performance measurement & debug logging
			MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


		end # InfoLoggerCommand

	end #module QT

end #module MobyController
