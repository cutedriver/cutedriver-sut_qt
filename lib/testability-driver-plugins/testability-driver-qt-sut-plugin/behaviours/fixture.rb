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

		module Fixture

			include MobyBehaviour::QT::Behaviour


			# Instructs the SUT to call fixture - still stub
			# === params
			# === returns
			# === raises
			def fixture( fixture_name, fixture_method, parameters_hash = {} )

				Kernel::raise ArgumentError.new("Fixture name -parameter was of wrong type: expected 'String' was '%s'" % fixture_name.class.to_s) unless fixture_name.kind_of?( String )
				Kernel::raise ArgumentError.new("Fixture method -parameter was of wrong type: expected 'String' was '%s'" % fixture_method.class.to_s) unless fixture_method.kind_of?( String )

				ret = nil

				begin
				  #for sut send the fixture command to qttasserver (appid nil)
				  if self.class == MobyBase::SUT
					ret = self.execute_command( MobyCommand::Fixture.new( nil, self.id, :Application, fixture_name, fixture_method, parameters_hash ) )
				  else
					ret = @sut.execute_command( MobyCommand::Fixture.new( get_application_id, self.id, self.attribute( 'objectType' ).intern, fixture_name, fixture_method, parameters_hash ) )
				  end				  
				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour", 
						"FAIL;Failed when calling fixture with name #{fixture_name} method #{fixture_method} parameters #{parameters_hash.inspect}.;#{id.to_s};sut;{};fixture;"

					Kernel::raise MobyBase::BehaviourError.new("Fixture", "Failed to execute fixture name #{fixture_name} method #{fixture_method}")
				end

				MobyUtil::Logger.instance.log "behaviour", 
					"PASS;The fixture command was executed successfully with name #{fixture_name} method #{fixture_method} parameters #{parameters_hash.inspect}.;#{id.to_s};sut;{};fixture;"

				ret

			end

			def async_fixture( fixture_name, fixture_method, parameters_hash = {} )

				Kernel::raise ArgumentError.new("Fixture name -parameter was of wrong type: expected 'String' was '%s'" % fixture_name.class.to_s) unless fixture_name.kind_of?( String )
				Kernel::raise ArgumentError.new("Fixture method -parameter was of wrong type: expected 'String' was '%s'" % fixture_method.class.to_s) unless fixture_method.kind_of?( String )

				ret = nil

				begin
				  #for sut send the fixture command to qttasserver (appid nil)
				  if self.class == MobyBase::SUT
					ret = self.execute_command( MobyCommand::Fixture.new( nil, self.id, :Application, fixture_name, fixture_method, parameters_hash, true ) )
				  else
					ret = @sut.execute_command( MobyCommand::Fixture.new( get_application_id, self.id, self.attribute( 'objectType' ).intern, fixture_name, fixture_method, parameters_hash, true ) )
				  end
				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , 
						"FAIL;Failed when calling async_fixture with name #{fixture_name} method #{fixture_method} parameters #{parameters_hash.inspect}.;#{id.to_s};sut;{};fixture;"

					Kernel::raise MobyBase::BehaviourError.new("Fixture", "Failed to execute async_fixture name #{fixture_name} method #{fixture_method}")
				end

				MobyUtil::Logger.instance.log "behaviour", 
					"PASS;The fixture command was executed successfully with name #{fixture_name} method #{fixture_method} parameters #{parameters_hash.inspect}.;#{id.to_s};sut;{};fixture;"

				ret

			end

			# enable hooking for performance measurement & debug logging
			MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

		end

	end
end
