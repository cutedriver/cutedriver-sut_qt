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
	
	module Application 
	  
      include MobyUtil::MessageComposer

	  def set_adapter( adapter )
		
		@sut_adapter = adapter
		
	  end           
	  
	  # Execute the command). 
	  # Sends the message to the device using the @sut_adapter (see base class)     
	  # == params         
	  # == returns
	  # == raises
	  # ArgumentError: raised if unsupported command type   
	  def execute()
		
		return_response_crc = false
		
		# application ui state
		if @_command == :State
		  
		  command_xml = state_message()
		  return_response_crc = true
		  
		  # launch application
		elsif @_command == :Run
		  command_xml = run_message()

		  # close
		elsif @_command == :Close
		  command_xml = close_message()

		  # close qttas
		elsif @_command == :CloseQttas
		  #params = {'uid' => '0'}
		  command_xml = make_xml_message({:service => 'closeApplication'},'Close',{'uid' => '0'})

		  # kill application
		elsif @_command == :Kill
		  command_xml = make_xml_message({:service => 'closeApplication'},'Kill',{'uid' => @_application_uid})

		  # list application -- raises exception??
		elsif @_command == :List
		  Kernel::raise ArgumentError.new( "Unknown command! " + @_command.to_s )

		  # list applications		      
		elsif @_command == :ListApps
		  service_details = {:service => 'listApps', :name => @_application_name, :id => @_application_uid}
		  command_xml = make_xml_message(service_details, 'listApps', nil )

		  # list started applications		      
		elsif @_command == :ListStartedApps
		  service_details = {:service => 'startedApps', :name => @_application_name, :id => @_application_uid}
		  command_xml = make_xml_message(service_details, 'startedApps', nil )

		  # list crashed applications
		elsif @_command == :ListCrashedApps
		  service_details = {:service => 'listCrashedApps', :name => @_application_name, :id => @_application_uid}
		  command_xml = make_xml_message(service_details, 'listCrashedApps', nil )

		  # shell command
		elsif @_command == :Shell
		  command_xml = make_xml_message({:service => 'shellCommand'}, 'shellCommand', @_flags, @_application_name)

		  # kill all application started by agent_qt
		elsif @_command == :KillAll
		  command_xml = make_xml_message({:service =>'kill'},'Kill', nil)

		  # tap screen
		elsif @_command == :TapScreen
		  command_xml = make_xml_message({:service =>'tapScreen'}, 'TapScreen', params)

		  # bring application to foreground
		elsif @_command == :BringToForeground
		  command_xml = make_xml_message({:service => 'bringToForeground'},'BringToForeground', {'pid' => @_application_uid})
		  
		  # system info
		elsif @_command == :SystemInfo
		  command_xml = make_xml_message({:service => 'systemInfo'}, 'systemInfo', nil)
		  
		  # start process memory logging
		elsif @_command == :ProcessMemLoggingStart
		  
		  parameters = {
			'thread_name' => @_application_name, 
			'file_name' => @_flags[ :file_name ],
			'timestamp' => @_flags[ :timestamp ],
			'interval_s' => @_flags[ :interval_s] }

		  command_xml = make_xml_message({:service => 'resourceLogging'}, 'ProcessMemLoggingStart', parameters)


		  # stop process memory logging
		elsif @_command == :ProcessMemLoggingStop
		  parameters = {'thread_name' => @_application_name,
			'return_data' => @_flags[ :return_data ]}

		  command_xml = make_xml_message({ :service =>'resourceLogging'}, 'ProcessMemLoggingStop',parameters)

		  # start CPU load generating
		elsif @_command == :CpuLoadStart
		  parameters =  {'cpu_load' => @_flags[ :cpu_load ]}
		  command_xml = make_xml_message({:service => 'resourceLogging'},'CpuLoadStart',parameters)

		  # stop CPU load generating
		elsif @_command == :CpuLoadStop
		  command_xml = make_xml_message({:service => 'resourceLogging'},'CpuLoadStop', nil)

		  # unknown command
		else
		  Kernel::raise ArgumentError.new( "Unknown command! " + @_command.to_s )
		end
		
		message = Comms::MessageGenerator.generate( command_xml )
		@sut_adapter.send_service_request( message, return_response_crc ) if message		
	  end

	end # application

  end  # QT  	

end # MobyController
