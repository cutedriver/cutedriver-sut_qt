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
		  command_xml = make_message({:service => 'closeApplication'},'Close',{'uid' => '0'})

		  # kill application
		elsif @_command == :Kill
		  command_xml = make_message({:service => 'closeApplication'},'Kill',{'uid' => @_application_uid})

		  # list application -- raises exception??
		elsif @_command == :List
		  Kernel::raise ArgumentError.new( "Unknown command! " + @_command.to_s )

		  # list applications		      
		elsif @_command == :ListApps
		  service_details = {:service => 'listApps', :name => @_application_name, :id => @_application_uid}
		  command_xml = make_message(service_details, 'listApps', nil )

		  # list crashed applications
		elsif @_command == :ListCrashedApps
		  service_details = {:service => 'listCrashedApps', :name => @_application_name, :id => @_application_uid}
		  command_xml = make_message(service_details, 'listCrashedApps', nil )

		  # shell command
		elsif @_command == :Shell
		  command_xml = make_message({:service => 'shellCommand'}, 'shellCommand', @_flags, @_application_name)

		  # kill all application started by agent_qt
		elsif @_command == :KillAll
		  command_xml = make_message({:service =>'kill'},'Kill', nil)

		  # tap screen
		elsif @_command == :TapScreen
		  command_xml = make_message({:service =>'tapScreen'}, 'TapScreen', params)

		  # bring application to foreground
		elsif @_command == :BringToForeground
		  command_xml = make_message({:service => 'bringToForeground'},'BringToForeground', {'pid' => @_application_uid})
		  
		  # system info
		elsif @_command == :SystemInfo
		  command_xml = make_message({:service => 'systemInfo'}, 'systemInfo', nil)
		  
		  # start process memory logging
		elsif @_command == :ProcessMemLoggingStart
		  
		  parameters = {
			'thread_name' => @_application_name, 
			'file_name' => @_flags[ :file_name ],
			'timestamp' => @_flags[ :timestamp ],
			'interval_s' => @_flags[ :interval_s] }

		  command_xml = make_message({:service => 'resourceLogging'}, 'ProcessMemLoggingStart', parameters)


		  # stop process memory logging
		elsif @_command == :ProcessMemLoggingStop
		  parameters = {'thread_name' => @_application_name,
			'return_data' => @_flags[ :return_data ]}

		  command_xml = make_message({ :service =>'resourceLogging'}, 'ProcessMemLoggingStop',paremeters)

		  # start CPU load generating
		elsif @_command == :CpuLoadStart
		  parameters =  {'cpu_load' => @_flags[ :cpu_load ]}
		  command_xml = make_message({:service => 'resourceLogging'},'CpuLoadStart',paremeters)

		  # stop CPU load generating
		elsif @_command == :CpuLoadStop
		  command_xml = make_message({:service => 'resourceLogging'},'CpuLoadStop', nil)

		  # unknown command
		else
		  Kernel::raise ArgumentError.new( "Unknown command! " + @_command.to_s )
		end
		
		message = Comms::MessageGenerator.generate( command_xml )
		@sut_adapter.send_service_request( message, return_response_crc ) if message		
	  end

	  private 

	  def make_parametrized_message( service_details, command_name, params, command_params = {} )

		Nokogiri::XML::Builder.new{
		  TasCommands( service_details ) {
			Target( :TasId => "Application" ) {
			  Command( ( params || {} ).merge( :name => command_name ) ){
				command_params.collect{ | name, value | 
				  param( :name => name, :value => value ) 
				}					        
			  }
			}
		  }
		}.to_xml

	  end

	  def make_message( service_details, command_name, params, command_value = nil )

		Nokogiri::XML::Builder.new{
		  TasCommands( service_details ) {
			Target( :TasId => "Application" ) {
			  Command( command_value || "", ( params || {} ).merge( :name => command_name ) )
			}
		  }
		}.to_xml		  

	  end


	  def encode_string( source )
		source = source.to_s
		source.gsub!( '&', '&amp;' );
		source.gsub!( '>', '&gt;' );
		source.gsub!( '<', '&lt;' );
		source.gsub!( '"', '&quot;' );
		source.gsub!( '\'', '&apos;' );
		source
	  end

	  def make_filters

		params = {}

		# get sut paramteres only once, store to local variable
		sut_parameters = MobyUtil::Parameter[ @_sut.id ]

		params[ 'filterProperties' ] = $last_parameter if sut_parameters[ :filter_properties, nil ]
		params[ 'pluginBlackList'  ] = $last_parameter if sut_parameters[ :plugin_blacklist,  nil ]
		params[ 'pluginWhiteList'  ] = $last_parameter if sut_parameters[ :plugin_whitelist,  nil ]

		case sut_parameters[ :filter_type, 'none' ]
		  
		when 'dynamic'

		  # updates the filter with the current backtrace file list
		  MobyUtil::DynamicAttributeFilter.instance.update_filter( caller( 0 ) ) 

		  white_list = MobyUtil::DynamicAttributeFilter.instance.filter_string
		  params['attributeWhiteList'] = white_list if white_list
		  
		when 'static'

		  params['attributeBlackList'] = $last_parameter if sut_parameters[ :attribute_blacklist, nil ]
		  params['attributeWhiteList'] = $last_parameter if sut_parameters[ :attribute_whitelist, nil ]
		  
		end

		params		

	  end
	  
	  def state_message
		app_details = { :service => 'uiState', :name => @_application_name, :id => @_application_uid }
		app_details[ :applicationUid ] = @_refresh_args[ :applicationUid ] if @_refresh_args.include?( :applicationUid )
		
		case MobyUtil::Parameter[ @_sut.id ][ :filter_type, 'none' ]
		when 'none' 
		  command_xml = make_message( app_details, 'UiState', @_flags || {} )
		when 'dynamic'
		  params = @_flags || {}
		  params[ :filtered ] = 'true'
		  command_xml = make_parametrized_message( app_details, 'UiState', params, make_filters )
		else
		  command_xml = make_parametrized_message( app_details, 'UiState', @_flags || {}, make_filters )
		end
		command_xml		
	  end

	  def run_message
		#clone to not make changes permanent
		arguments = MobyUtil::Parameter[ @_sut.id ][ :application_start_arguments, "" ].clone 
		if @_arguments
		  arguments << "," unless arguments.empty?
		  arguments << @_arguments
		end

		parameters = { 
		  'application_path' => @_application_name, 
		  'arguments' => arguments, 
		  'environment' => @_environment, 
		  'events_to_listen' => @_events_to_listen, 
		  'signals_to_listen' => @_signals_to_listen, 
		  'start_command' => @_start_command 
		}

		make_message({:service => 'startApplication'}, 'Run', parameters)				
	  end

	  def close_message
		sut_id = @_sut.id

		parameters = {
		  'uid' => @_application_uid, 
		  'kill' => ( @_flags || {} )[ :force_kill ] || MobyUtil::Parameter[ sut_id ][ :application_close_kill ], 
		  'wait_time' => MobyUtil::Parameter[ sut_id ][ :application_close_wait ] 		  
		}

		make_message({:service => 'closeApplication', :id => @_application_uid }, 'Close', parameters)
	  end
	  
	  # enable hooking for performance measurement & debug logging
	  MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )
	end #application

  end  # QT  	

end # MobyController
