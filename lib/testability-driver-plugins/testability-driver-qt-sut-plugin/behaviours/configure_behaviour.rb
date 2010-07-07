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

	module ConfigureBehaviour

	  include MobyBehaviour::QT::Behaviour

	  @@_valid_levels = [ :FATAL, :ERROR, :INFO, :WARNING, :DEBUG ]

	  def enable_logger
		configure_logger( {:logEnabled => true} )
	  end
	  
	  def disable_logger		
		configure_logger( {:logEnabled => false} )
	  end

	  def set_log_level(level)
		configure_logger( {:logLevel => level} )
	  end
	  
	  def set_log_folder(folder)
		configure_logger( {:logFolder => folder} )
	  end

	  def log_to_qdebug(to_qdebug = true)
		configure_logger( {:logToQDebug => to_qdebug} )
	  end

	  def log_qdebug(include = true)
		configure_logger( {:logQDebug => include} )
	  end

	  def set_log_size(size)
		configure_logger( {:logSize => size} )
	  end

	  def clear_log
		configure_logger( {:clearLog => true} )
	  end

	  # Set the logger to log listed events. Events have to be separated by comma.
	  # e.g MouseEvent, Paint
	  # The event name does not have to be complete. e.g Mouse will log all events with the
	  # word mouse.
	  def log_events( event_list = '')
		begin 

		  params = {:logEvents => 'true'}
		  perform_command( MobyCommand::ConfigureCommand.new( "configureEventLogging", params, event_list ) )		

		rescue Exception => e
		  
		  MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to enable event logging. With event_list \"#{event_list};log_events"
		  Kernel::raise e        

		end      

		MobyUtil::Logger.instance.log "behaviour" , "PASS;Event logging enabled. With event_list \"#{event_list};log_events"

	  end

	  # Stop loggin events.
	  def stop_event_logging
		begin

		  params = {:logEvents => 'false'}
		  perform_command( MobyCommand::ConfigureCommand.new( "configureEventLogging", params) )		

		rescue Exception => e
		  
		  MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to stop event logging.;stop_event_logging"
		  Kernel::raise e        

		end      

		MobyUtil::Logger.instance.log "behaviour" , "PASS;Event logging stopped.;stop_event_logging"

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
		  
		  MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to configure logger. With params \"#{params_hash.to_s};configure_logger"
		  Kernel::raise e        

		end      

		MobyUtil::Logger.instance.log "behaviour" , "PASS;Succesfully configured logger. With params \"#{params_hash.to_s};configure_logger"

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
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


	end
  end
end
