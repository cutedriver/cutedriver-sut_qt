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
      #   description: Name of the fixture. Fixture mapping is in the tdriver_parameters.xml file.
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

        # verify that arguments were given in correct format
        fixture_name.check_type String, 'wrong argument type $1 for fixture name (expected $2)'

        fixture_method.check_type String, 'wrong argument type $1 for fixture method name (expected $2)'

        parameters_hash.check_type Hash, 'wrong argument type $1 for fixture parameters (expected $2)'

		    result = nil

		    begin

          # default parameters
		      params = { :name => fixture_name, :command_name => fixture_method, :parameters => parameters_hash, :async => false }

	        # for sut send the fixture command to qttasserver (appid nil)
          if sut?

			      params.merge!( :application_id => nil, :object_id => @id, :object_type => :Application )

          else

			      params.merge!( :application_id => get_application_id, :object_id => @id, :object_type => attribute( 'objectType' ).to_sym )

          end

          result = @sut.execute_command( MobyCommand::Fixture.new( params ) )
				    
		    rescue

		      $logger.behaviour "FAIL;Failed when calling fixture with name #{ fixture_name.inspect } method #{ fixture_method.inspect } parameters #{ parameters_hash.inspect }.;#{ @id.to_s };sut;{};fixture;"

		      raise MobyBase::BehaviourError.new( "Fixture", "Failed to execute fixture name #{ fixture_name.inspect } method #{ fixture_method.inspect }" )

		    end

		    $logger.behaviour "PASS;The fixture command was executed successfully with name #{ fixture_name.inspect } method #{ fixture_method.inspect } parameters #{ parameters_hash.inspect }.;#{ @id.to_s };sut;{};fixture;"

		    result

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
      #   description: Name of the fixture. Fixture mapping is in the tdriver_parameters.xml file
      #   example: tasfixture
      #
      # fixture_method
      #  String
      #   description: Name of the action to be executed in the fixture
      #   example: callApi
      #    
      # parameters_hash
      #  Hash
      #   description: Optional hash of parameters passed on to the fixture
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

        # verify that arguments were given in correct format
        fixture_name.check_type String, 'wrong argument type $1 for fixture name (expected $2)'

        fixture_method.check_type String, 'wrong argument type $1 for fixture method name (expected $2)'

        parameters_hash.check_type Hash, 'wrong argument type $1 for fixture parameters (expected $2)'

		    result = nil

        begin

          # default parameters
          params = { :name => fixture_name, :command_name => fixture_method, :parameters => parameters_hash, :async => true }

          # for sut send the fixture command to qttasserver (appid nil)
          if sut?

            params.merge!( :application_id => nil, :object_id => @id, :object_type => :Application )

          else

            params.merge!( :application_id => get_application_id, :object_id => @id, :object_type => attribute( 'objectType' ).to_sym )

          end

          result = @sut.execute_command( MobyCommand::Fixture.new( params ) )

        rescue

          $logger.behaviour "FAIL;Failed when calling async_fixture with name #{ fixture_name.inspect } method #{ fixture_method.inspect } parameters #{ parameters_hash.inspect }.;#{ @id.to_s };sut;{};fixture;"

          raise MobyBase::BehaviourError.new("Fixture", "Failed to execute async_fixture name #{ fixture_name.inspect } method #{ fixture_method.inspect }")

        end

        $logger.behaviour "PASS;The fixture command was executed successfully with name #{ fixture_name.inspect } method #{ fixture_method.inspect } parameters #{ parameters_hash.inspect }.;#{ @id.to_s };sut;{};fixture;"

        result

	    end

      # == nodoc
      def fixtures

        # pass call to fixtures service object          
        TDriver::FixtureService.new( :target => self )

      end

	    # enable hooking for performance measurement & debug logging
	    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	  end # Fixture

  end # QT

end # MobyBehaviour
