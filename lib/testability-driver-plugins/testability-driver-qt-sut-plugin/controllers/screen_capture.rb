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

		module ScreenCapture 

			def set_adapter( adapter )      
				@sut_adapter = adapter
			end

			def execute
				@sut_adapter.send_service_request(
					Comms::MessageGenerator.generate(
						Nokogiri::XML::Builder.new{
							TasCommands( :id=> 1, :service => "screenShot" ) {
								Target( :TasId => 1, :type => "Application" ) {
									Command( :name => "Screenshot", :format => @context.image_mime_type, :draw => @context.redraw.to_s )
								}
							}
						}.to_xml
					)
				)

			end

		end # ScreenCapture
	end # QT
end # MobyController

MobyUtil::Logger.instance.hook_methods( MobyController::QT::ScreenCapture )
