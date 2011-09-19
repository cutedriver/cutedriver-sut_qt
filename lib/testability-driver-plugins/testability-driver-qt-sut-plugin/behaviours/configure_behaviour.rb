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
    # Behaviours for configuring the logging services on the target.
    #
    # == behaviour
    # QtConfigureBehaviour
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == sut_type
    # qt
    #
    # == input_type
    # All
    #
    # == sut_version
    # *
    #
    # == objects
    # sut;application
    #
	  module ConfigureBehaviour

	    include MobyBehaviour::QT::Behaviour

	    @@_valid_levels = [ :FATAL, :ERROR, :INFO, :WARNING, :DEBUG ]

      # == description
      # Enabled the logging on the target for the given application or sut (qttasserver). 
      # Logs are written to the target in (/logs/testability)
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
	    def enable_logger
  		  configure_logger( {:logEnabled => true} )
	    end

      # == description
      # Disable the logging on the target for the given application or sut (qttasserver). 
      # Logs are left as they are.
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
	    def disable_logger		
  		  configure_logger( {:logEnabled => false} )
	    end

      # == description
      # Set the log level for the application or sut (qttasserver). Affects only the running process. 
      # Will not be stored as permanent setting.
      #
      # == arguments
      # level
      #  Symbol 
      #   description:
      #    The log level.
      #    See [link="#log_levels_table"]Valid log levels table[/link] for valid keys. 
      #    example: :INFO
      #
      # == tables
      # log_levels_table
      #  title: Valid log levels
      #  |Level|Type|Description|
      #  |:FATAL|Symbol|Log fatal level message|
      #  |:ERROR|Symbol|Log fatal and error level messages|
      #  |:INFO|Symbol|Log fatal, error and info level messages|
      #  |:WARNING|Symbol|Log fatal, error, info and warning level messages|
      #  |:DEBUG|Symbol|Log all messages|
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given level is not valid.
	    def set_log_level(level)
  		  configure_logger( {:logLevel => level} )
	    end
	    
      # == description
      # Change the folder to where the logs are written to for the application or sut (qttasserver).
      #
      # == arguments
      # folder
      #  String 
      #   description:
      #    New location for the logs.
      #    example: '/tmp/logs'
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
	    def set_log_folder(folder)
  		  configure_logger( {:logFolder => folder} )
	    end

      # == description
      # Can be used to set logging to be done to qDebug. All tdriver target logging
      # will go to qDebug not the log file.
      #
      # == arguments
      # to_qdebug
      #  Boolean
      #   description:
      #    True to logs message to qDebug instead of a file.	  
      #    example: true
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
	    def log_to_qdebug(to_qdebug = true)
  		  configure_logger( {:logToQDebug => to_qdebug} )
	    end

      # == description
      # Set the qDebug message to be append to the logs or not.
      # By default qDebug messages are not written to the logs.
      #
      # == arguments
      # include
      #  Boolean
      #   description:
      #    True to log qDebug messages and false to not
      #    example: true
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
	    def log_qdebug(include = true)
  		  configure_logger( {:logQDebug => include} )
	    end

      # == description
      # Set max size for the log file. When the level is reached the log file is renamed
      # as old_"name of log file".log and a new file is started. By default the size is 
      # 100000.
      #
      # == arguments
      # size
      #  Fixnum
      #   description:
      #    The new log file size
      #    example: 500000
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
	    def set_log_size(size)
  		  configure_logger( {:logSize => size} )
	    end

      # == description
      # Clears the log file.	  
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
	    def clear_log
  		  configure_logger( {:clearLog => true} )
	    end

      # == description
      # Set the logger to log listed events. Events have to be separated by comma.
      # e.g MouseEvent, Paint
      # The event name does not have to be complete. e.g Mouse will log all events with the
      # word Mouse.
      # 
      # == arguments
      # event_list
      #  String
      #   description:
      #    Comma separated list of events
      #    example: 'Mouse','Touch'
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #	  
	    def log_events( event_list = '')
		    begin 

		      params = {:logEvents => 'true'}
		      perform_command( MobyCommand::ConfigureCommand.new( "configureEventLogging", params, event_list ) )		

		    rescue Exception => e
		      
		      $logger.behaviour "FAIL;Failed to enable event logging. With event_list \"#{event_list};log_events"
		      raise e        

		    end      

		    $logger.behaviour "PASS;Event logging enabled. With event_list \"#{event_list};log_events"

	    end

      # == description
      # Stop logging events.
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #	  
	    def stop_event_logging
		    begin

		      params = {:logEvents => 'false'}
		      perform_command( MobyCommand::ConfigureCommand.new( "configureEventLogging", params) )		

		    rescue Exception => e
		      
		      $logger.behaviour "FAIL;Failed to stop event logging.;stop_event_logging"
		      raise e        

		    end      

		    $logger.behaviour "PASS;Event logging stopped.;stop_event_logging"

	    end

    private
	    
	    # Configure the logger for qttasserver and plugins
	    # Parameters are to be passed as a hash with one or more
	    # of the following values:
	    # :logLevel => :DEBUG (or :FATAL, :ERROR, :INFO or :WARNING. DEBUG will log the most)
   	  # :logToQDebug => true/false
	    # :logFolder => '/tmp/logs/'
	    # :logQDebug => true/false
	    # :logSize => 10000
	    # :logEnabled => true/false
	    def configure_logger( params_hash  = nil)

		    begin 
		      raise ArgumentError.new( "No parameters given." ) unless params_hash

		      log_level = params_hash[:logLevel]  

		      if log_level
			    raise ArgumentError.new( "Invalid log level." ) unless @@_valid_levels.include?(log_level)
		      end

		      perform_command(MobyCommand::ConfigureCommand.new( "configureLogger", params_hash ))  
		      
		    rescue Exception => e
		      
		      $logger.behaviour "FAIL;Failed to configure logger. With params \"#{params_hash.to_s};configure_logger"
		      raise e        

		    end      

		    $logger.behaviour "PASS;Succesfully configured logger. With params \"#{params_hash.to_s};configure_logger"

	    end

	    def perform_command(command)
		
		    if self.class == MobyBase::SUT
		      execute_command( command ) 
		    else
		      command.application_id = get_application_id
		      @sut.execute_command( command )
		    end

      end
	    
	    # enable hooking for performance measurement & debug logging
	    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	  end # ConfigureBehaviour

  end # QT

end # MobyBehaviour
