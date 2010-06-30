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

	  # Execute the command). 
	  # Sends the message to the device using the @sut_adapter (see base class)     
	  # == params         
	  # == returns
	  # == raises
	  # ArgumentError: raised if unsupported command type   

	  def execute()

		message = nil

		return_response_crc = false

		if @_command == :Run

		  param_arguments = MobyUtil::Parameter[ @_sut.id ][ :application_start_arguments, "" ]

		  arguments = ""
		  arguments << param_arguments if param_arguments != ""

		  if @_arguments
			arguments << "," if param_arguments != ""
			arguments << @_arguments
		  end
		  params = {'application_path' => get_application(), 'arguments' => arguments, 'environment' => @_environment, 'events_to_listen' => @_events_to_listen, 'signals_to_listen' => @_signals_to_listen, 'start_command' => @_start_command}
		  command_xml = make_message( 'startApplication','Run', params )

		elsif @_command == :Close
      flags = {}
		  flags.merge!(get_flags) if get_flags
      if (!flags.empty?) 
        #puts "flags " + flags[:force_kill] .to_s
        params = {'uid' => @_application_uid.to_s,'kill' => flags[:force_kill] , 'wait_time' => MobyUtil::Parameter[ @_sut.id ][ :application_close_wait ]}
      else
        params = {'uid' => @_application_uid.to_s,'kill' => MobyUtil::Parameter[ @_sut.id ][ :application_close_kill ], 'wait_time' => MobyUtil::Parameter[ @_sut.id ][ :application_close_wait ]}
		  end
		  command_xml = make_message( 'closeApplication','Close', params, @_application_uid.to_s )

		elsif @_command == :CloseQttas
		  params = {'uid' => '0'}
		  command_xml = make_message( 'closeApplication','Close', {'uid' => '0'} )

		elsif @_command == :Kill
		  command_xml = make_message( 'closeApplication','Kill', {'uid' => @_application_uid.to_s})

		elsif @_command == :List
		  Kernel::raise ArgumentError.new("Unknown command! " + @_command.to_s )        

		elsif @_command == :State        	
		  params = {}
		  params.merge!(get_flags) if get_flags
		  if MobyUtil::Parameter[ @_sut.id ][ :filter_type,'none' ] == 'none'	  
			command_xml = make_message( 'uiState','UiState', params, @_application_uid, get_application)
		  else			
			params[:filtered] = 'true' if MobyUtil::Parameter[ @_sut.id ][ :filter_type,'none' ] == 'dynamic'	  
			command_xml = make_parametrized_message( 'uiState','UiState', params, @_application_uid, get_application, make_filters )
		  end
		  return_response_crc = true
		  
		elsif @_command == :ListApps        
		  command_xml = make_message( 'listApps','listApps', nil, @_application_uid, get_application )

		elsif @_command == :ListCrashedApps
		  command_xml = make_message('listCrashedApps', 'listCrashedApps', nil, @_application_uid, get_application)

		elsif @_command == :Shell                
		  command_xml = make_message( 'shellCommand','shellCommand', @_flags, nil, nil, @_application_name )

		elsif @_command == :KillAll
		  command_xml = make_message( 'kill','Kill', nil)

		elsif @_command == :TapScreen
		  command_xml = make_message( 'tapScreen','TapScreen', params)

		elsif @_command == :BringToForeground
		  command_xml = make_message('bringToForeground', 'BringToForeground', {'pid' => @_application_uid.to_s})
		  
		elsif @_command == :SystemInfo
		  command_xml = make_message('systemInfo', 'systemInfo', nil)

    elsif @_command == :ProcessMemLoggingStart
      command_xml = make_message(
        'resourceLogging',
        'ProcessMemLoggingStart',
          {'thread_name' => @_application_name,
           'file_name' => @_flags[:file_name],
           'timestamp' => @_flags[:timestamp],
           'interval_s' => @_flags[:interval_s]})

    elsif @_command == :ProcessMemLoggingStop
      command_xml = make_message(
        'resourceLogging',
        'ProcessMemLoggingStop',
          {'thread_name' => @_application_name,
           'return_data' => @_flags[:return_data]})

		else
		  Kernel::raise ArgumentError.new( "Unknown command! " + @_command.to_s )

		end
		message = Comms::MessageGenerator.generate( command_xml )
		@sut_adapter.send_service_request( message, return_response_crc ) if message

	  end

	  def set_adapter( adapter )
		@sut_adapter = adapter
	  end           

	  private 

	  def make_parametrized_message( service_name, command_name, params, application_id = nil, application_name = nil, command_params = {} )

		Nokogiri::XML::Builder.new{
		  TasCommands( :id => application_id, :name => application_name, :service => service_name ) {
			Target( :TasId => "Application" ) {
			  Command( ( params || {} ).merge( :name => command_name ) ){
				command_params.collect{ | name, value | param( :name => name, :value => value ) }					        
			  }
			}
		  }
		}.to_xml
	  end

	  def make_message( service_name, command_name, params, application_id = nil, application_name = nil, command_value = nil )

		Nokogiri::XML::Builder.new{
		  TasCommands( :id => application_id, :name => application_name, :service => service_name ) {
			Target( :TasId => "Application" ) {
			  Command( command_value || "", ( params || {} ).merge( :name => command_name ) )
			}
		  }
		}.to_xml

	  end


	  def encode_string(source)
		source = source.to_s
		source.gsub!( "&", "&amp;" );
		source.gsub!( ">", "&gt;" );
		source.gsub!( "<", "&lt;" );
		source.gsub!( "\"", "&quot;" );
		source.gsub!( "\'", "&apos;" );
		source
	  end

	  def make_filters

		params = Hash.new
		filter_properties = MobyUtil::Parameter[ @_sut.id ][:filter_properties, nil]
		plugin_blacklist = MobyUtil::Parameter[ @_sut.id ][:plugin_blacklist, nil]
		plugin_whitelist = MobyUtil::Parameter[ @_sut.id ][:plugin_whitelist, nil]
		params['filterProperties'] = filter_properties if filter_properties
		params['pluginBlackList'] = plugin_blacklist if plugin_blacklist
		params['pluginWhiteList'] = plugin_whitelist if plugin_whitelist

		if MobyUtil::Parameter[ @_sut.id ][ :filter_type,'none' ] == 'dynamic'
		  MobyUtil::DynamicAttributeFilter.instance.update_filter( caller( 0 ) ) # updates the filter with the current backtrace file list
		  white_list = attribute_filter_string = MobyUtil::DynamicAttributeFilter.instance.filter_string
		  params['attributeWhiteList'] = white_list if white_list
		elsif MobyUtil::Parameter[ @_sut.id ][ :filter_type,'none' ] == 'static'
		  black_list = MobyUtil::Parameter[ @_sut.id ][ :attribute_blacklist,nil ]
		  white_list = MobyUtil::Parameter[ @_sut.id ][ :attribute_whitelist,nil ]
		  params['attributeBlackList'] = black_list if black_list
		  params['attributeWhiteList'] = white_list if white_list
		end
		params		

	  end

	end #module Application    

  end #module QT  

end #module MobyController

MobyUtil::Logger.instance.hook_methods( MobyController::QT::Application )
