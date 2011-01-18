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
    # Fixture specific behaviours
    #
    # == behaviour
    # QtFixture
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # *
    #
    # == sut_type
    # qt
    #
    # == sut_version
    # *
    #
    # == objects
    # sut;*
    #
	module Fixture

	  include MobyBehaviour::QT::Behaviour


      # == description
      # Sends a fixture call to the target. The fixture will be executed either
	  # inside the application process or the qttasserver process (if used for sut). 
	  # The fixture will get a pointer to the object to which this call is made to.
	  # 
      #
      # == arguments
      # fixture_name
      #  String
      #   description: Name of the fixture. Fixture mapping is in the tdriverparameters.xml file.
      #   example: tasfixture
	  #
	  # fixture_method
	  #  String
      #   description: Name of the action to be executed in the fixture.
      #   example: callApi
	  #    
	  # parameters_hash
	  #  Hash
      #   description: Optional hash of pareters passed on to the fixture.
      #   example: {:name => 'John'}
	  #
      # == returns
      # QString
      #   description: The value returned but the fixture.
      #   example: OK
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
      #    
	  def fixture( fixture_name, fixture_method, parameters_hash = {} )

		Kernel::raise ArgumentError.new("Fixture name -parameter was of wrong type: expected 'String' was '%s'" % fixture_name.class.to_s) unless fixture_name.kind_of?( String )
		Kernel::raise ArgumentError.new("Fixture method -parameter was of wrong type: expected 'String' was '%s'" % fixture_method.class.to_s) unless fixture_method.kind_of?( String )

		ret = nil

		begin
		  params = {:name => fixture_name, :command_name => fixture_method, :parameters => parameters_hash, :async => false}
		  #for sut send the fixture command to qttasserver (appid nil)
		  if self.class == MobyBase::SUT
			params.merge!( {:application_id => nil, :object_id => self.id, :object_type => :Application} )
			ret = self.execute_command( MobyCommand::Fixture.new( params ) )
		  else
			params.merge!( {:application_id => get_application_id, :object_id => self.id, :object_type => self.attribute( 'objectType' ).intern} )
			ret = @sut.execute_command( MobyCommand::Fixture.new( params ) )
		  end				  
		rescue Exception => e

		  $logger.log "behaviour", 
			"FAIL;Failed when calling fixture with name #{fixture_name} method #{fixture_method} parameters #{parameters_hash.inspect}.;#{id.to_s};sut;{};fixture;"

		  Kernel::raise MobyBase::BehaviourError.new("Fixture", "Failed to execute fixture name #{fixture_name} method #{fixture_method}")
		end

		$logger.log "behaviour", 
		  "PASS;The fixture command was executed successfully with name #{fixture_name} method #{fixture_method} parameters #{parameters_hash.inspect}.;#{id.to_s};sut;{};fixture;"

		ret

	  end

      # == description
      # Sends a fixture call to the target. The fixture will be executed either
	  # inside the application process or the qttasserver process (if used for sut). 
	  # The fixture will get a pointer to the object to which this call is made to.
	  # This version of the fixture call is asynchronous. This means that no return value
	  # is returned.
	  # 
      #
      # == arguments
      # fixture_name
      #  String
      #   description: Name of the fixture. Fixture mapping is in the tdriverparameters.xml file.
      #   example: tasfixture
	  #
	  # fixture_method
	  #  String
      #   description: Name of the action to be executed in the fixture.
      #   example: callApi
	  #    
	  # parameters_hash
	  #  Hash
      #   description: Optional hash of pareters passed on to the fixture.
      #   example: {:name => 'John'}
	  #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
      #    
	  def async_fixture( fixture_name, fixture_method, parameters_hash = {} )

		Kernel::raise ArgumentError.new("Fixture name -parameter was of wrong type: expected 'String' was '%s'" % fixture_name.class.to_s) unless fixture_name.kind_of?( String )
		Kernel::raise ArgumentError.new("Fixture method -parameter was of wrong type: expected 'String' was '%s'" % fixture_method.class.to_s) unless fixture_method.kind_of?( String )

		ret = nil

		begin
		  params = {:name => fixture_name, :command_name => fixture_method, :parameters => parameters_hash, :async => true}
		  #for sut send the fixture command to qttasserver (appid nil)
		  if self.class == MobyBase::SUT
			params.merge!( {:application_id => nil, :object_id => self.id, :object_type => :Application} )
			ret = self.execute_command( MobyCommand::Fixture.new( params ) )
		  else
			params.merge!( {:application_id => get_application_id, :object_id => self.id, :object_type => self.attribute( 'objectType' ).intern} )
			ret = @sut.execute_command( MobyCommand::Fixture.new( params ) )
		  end
		rescue Exception => e

		  $logger.log "behaviour" , 
			"FAIL;Failed when calling async_fixture with name #{fixture_name} method #{fixture_method} parameters #{parameters_hash.inspect}.;#{id.to_s};sut;{};fixture;"

		  Kernel::raise MobyBase::BehaviourError.new("Fixture", "Failed to execute async_fixture name #{fixture_name} method #{fixture_method}")
		end

		$logger.log "behaviour", 
		  "PASS;The fixture command was executed successfully with name #{fixture_name} method #{fixture_method} parameters #{parameters_hash.inspect}.;#{id.to_s};sut;{};fixture;"

		ret

	  end

	  # enable hooking for performance measurement & debug logging
	  TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	end

  end
end
