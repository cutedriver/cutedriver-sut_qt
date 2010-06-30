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

		module Fixture 

			# Execute the command
			# Sends the message to the device using the @sut_adapter (see base class)     
			# == params         
			# == returns
			# == raises
			# NotImplementedError: raised if unsupported command type       
			def execute
				
				Kernel::raise ArgumentError.new( "Fixture '%s' not found for sut id '%s'" % [ @name, @sut_adapter.sut_id ] ) if ( fixture_plugin =  MobyUtil::Parameter[ @sut_adapter.sut_id.to_sym ][ :fixtures ][ @name.to_sym, nil ] ).nil?


				@sut_adapter.send_service_request(
					Comms::MessageGenerator.generate(
 						Nokogiri::XML::Builder.new{
							TasCommands( :id => @context.application_id, :transitions => @context.transitions, :service => "fixture", :async => @context.asynchronous ) {
								Target( :TasId => @context.object_id, :type => @context.object_type ) {
									Command( :name => "Fixture", :plugin => fixture_plugin, :method => @context.command ) {
										@context.params.collect{ | name, value | 
											param( :name => name, :value => value )
										}
									}
								}
							}
						}.to_xml
					)
				)

			end

			def set_adapter( adapter )
				@sut_adapter = adapter
			end

		end #module Fixture

	end #module QT

end #module MobyController

MobyUtil::Logger.instance.hook_methods( MobyController::QT::Fixture )
