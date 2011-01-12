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

# verify that TDriver is loaded
Kernel::raise RuntimeError.new( "This SUT plugin requires Testability Driver and cannot be launched in standalone mode" ) unless (defined?( MATTI ) || defined?( TDriver ))

module MobyPlugin

	module QT

		class SUT < MobyUtil::Plugin

			## plugin configuration, constructor and deconstructor methods
			def self.plugin_name

				# return plugin name as string
				"testability-driver-qt-sut-plugin"
				#File.basename( __FILE__, '.rb' ).downcase # => "tdriver-qt-sut-plugin" 

			end

			def self.plugin_type

				# return plugin type as symbol
				:sut

			end

			def self.register_plugin

				# load plugin specific implementation or other initialization etc.
				MobyUtil::FileHelper.load_modules( 

					# load utility module(s)
					'util/*.rb', 

					# sut adapter
					'sut/communication.rb', 

					# sut adapter
					'sut/adapter.rb', 

					# sut controller
					'sut/controller.rb', 

					# qt behaviour abstract
					'behaviours/behaviour.rb', 

					# load behaviour(s)
					'behaviours/*.rb', 

					# load command(s)
					'commands/*.rb',

					# load command controller(s)
					'controllers/*.rb'

				)

			end

			def self.unregister_plugin

				# unregister plugin

			end

			## plugin specific methods

			# return sut type that plugin implements
			def self.sut_type

				# return sut type as string
				"QT"

			end

			# returns SUT object - this method will be called from MobyBase::SUTFactory
			def self.make_sut( sut_id )

				# tcp/ip read/write timeouts, default: 15 (seconds)
				socket_read_timeout  = MobyUtil::Parameter[ sut_id ][ :socket_read_timeout,  "15" ].to_i
				socket_write_timeout = MobyUtil::Parameter[ sut_id ][ :socket_write_timeout, "15" ].to_i

				MobyBase::SUT.new(
					MobyBase::SutController.new( "QT", MobyController::QT::SutAdapter.new( sut_id, socket_read_timeout, socket_write_timeout ) ), 
					MobyBase::TestObjectFactory.instance, 
					sut_id 
				)

			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

			# register plugin
			MobyUtil::PluginService.instance.register_plugin( self ) # Note: self is MobyPlugin::QT::SUT

		end # SUT

	end # QT

end # MobyPlugin
