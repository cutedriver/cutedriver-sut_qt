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

		    #message = nil

		    return_response_crc = false

        # run
		    if @_command == :Run

          arguments = MobyUtil::Parameter[ @_sut.id ][ :application_start_arguments, "" ]

          if @_arguments
            arguments << "," unless arguments.empty?
            arguments << @_arguments
          end
		      
		      command_xml = make_message( 
            { 
              :service => 'startApplication' 
            }, 
            'Run', 
            { 
              'application_path' => @_application_name, 
              'arguments' => arguments, 
              'environment' => @_environment, 
              'events_to_listen' => @_events_to_listen, 
              'signals_to_listen' => @_signals_to_listen, 
              'start_command' => @_start_command 
            }
          )

        # close
		    elsif @_command == :Close

          sut_id = @_sut.id

		      command_xml = make_message( 
            { 
              :service => 'closeApplication', 
              :id => @_application_uid 
            },
            'Close', 
            { 
              'uid' => @_application_uid, 
              'kill' => ( @_flags || {} )[ :force_kill ] || MobyUtil::Parameter[ sut_id ][ :application_close_kill ], 
              'wait_time' => MobyUtil::Parameter[ sut_id ][ :application_close_wait ] 
            }
          )

        # close qttas
		    elsif @_command == :CloseQttas

		      #params = {'uid' => '0'}

		      command_xml = make_message( 
            { 
              :service => 'closeApplication' 
            }, 
            'Close', 
            { 
              'uid' => '0' 
            } 
          )

        # kill application
		    elsif @_command == :Kill

		      command_xml = make_message( 
            { 
              :service => 'closeApplication' 
            },
            'Kill', 
            { 
              'uid' => @_application_uid 
            } 
          )

        # list application -- raises exception??
		    elsif @_command == :List

		      Kernel::raise ArgumentError.new( "Unknown command! " + @_command.to_s )

        # application ui state
		    elsif @_command == :State

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

		      return_response_crc = true

        # list applications		      
		    elsif @_command == :ListApps

		      command_xml = make_message(
            {
              :service => 'listApps', 
              :name => @_application_name, 
              :id => @_application_uid 
            },
            'listApps', 
            nil 
          )

        # list crashed applications
		    elsif @_command == :ListCrashedApps

		      command_xml = make_message(
            {
              :service => 'listCrashedApps', 
              :name => @_application_name, 
              :id => @_application_uid 
            }, 
            'listCrashedApps', 
            nil
          )

        # shell command
		    elsif @_command == :Shell

		      command_xml = make_message( 
            { 
              :service => 'shellCommand'
            },
            'shellCommand', 
            @_flags, 
            @_application_name
          )

        # kill all application started by agent_qt
		    elsif @_command == :KillAll

		      command_xml = make_message(
            { 
              :service =>'kill' 
            },
            'Kill', 
            nil
          )

        # tap screen
		    elsif @_command == :TapScreen

		      command_xml = make_message( 
            { 
              :service =>'tapScreen'
            },
            'TapScreen', 
            params
          )

        # bring application to foreground
		    elsif @_command == :BringToForeground

		      command_xml = make_message( 
            { 
              :service => 'bringToForeground'
            }, 
            'BringToForeground', 
            {
              'pid' => @_application_uid 
            }
          )
		      
        # system info
		    elsif @_command == :SystemInfo

		      command_xml = make_message( 
            {
              :service => 'systemInfo'
            }, 
            'systemInfo', 
            nil
          )

        # start process memory logging
		    elsif @_command == :ProcessMemLoggingStart

		      command_xml = make_message(
            {
              :service => 'resourceLogging'
            },
			     'ProcessMemLoggingStart',
            {
              'thread_name' => @_application_name,
				      'file_name' => @_flags[ :file_name ],
              'timestamp' => @_flags[ :timestamp ],
              'interval_s' => @_flags[ :interval_s ]
            }
          )

        # stop process memory logging
		    elsif @_command == :ProcessMemLoggingStop

		      command_xml = make_message(
            {
              :service =>'resourceLogging'
            },
            'ProcessMemLoggingStop',
            { 
              'thread_name' => @_application_name,
              'return_data' => @_flags[ :return_data ]
            }
          )

        # unknown command
		    else

		      Kernel::raise ArgumentError.new( "Unknown command! " + @_command.to_s )

		    end

        message = Comms::MessageGenerator.generate( command_xml )

		    @sut_adapter.send_service_request( message, return_response_crc ) if message
	   
      end

    private 

	    def make_parametrized_message( service_details, command_name, params, command_params = {} )

=begin

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

=end

        params ||= {}
        params[ :name ] = command_name

        "<?xml version=\"1.0\"?><TasCommands#{ 

          service_details.collect{ | value | " #{ value.first }=\"#{ value.last }\"" }.to_s

        }><Target TasId=\"Application\"><Command#{ 

          params.collect{ | value | " #{ value.first }=\"#{ value.last }\"" }.to_s 

        }>#{

            command_params.collect{ | name, value | "<param name=\"#{ name }\" value=\"#{ value }\"/>" }.to_s

        }</Command></Target></TasCommands>"

	    end

	    def make_message( service_details, command_name, params, command_value = nil )

=begin

        Nokogiri::XML::Builder.new{
          TasCommands( service_details ) {
          Target( :TasId => "Application" ) {
            Command( command_value || "", ( params || {} ).merge( :name => command_name ) )
          }
          }
        }.to_xml

=end

        params ||= {}
        params[ :name ] = command_name

        "<?xml version=\"1.0\"?><TasCommands#{ 

          service_details.collect{ | value | " #{ value.first }=\"#{ value.last }\"" }.to_s

        }><Target TasId=\"Application\"><Command#{ 

          params.collect{ | value | " #{ value.first }=\"#{ value.last }\"" }.to_s 

        }>#{ command_value || "" }</Command></Target></TasCommands>"

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

		    params = Hash.new

        # get sut id parameter only once, store as local variable
        sut_id = @_sut.id

		    filter_properties = MobyUtil::Parameter[ sut_id ][ :filter_properties, nil ]
		    plugin_blacklist = MobyUtil::Parameter[ sut_id ][ :plugin_blacklist, nil ]
		    plugin_whitelist = MobyUtil::Parameter[ sut_id ][ :plugin_whitelist, nil ]

		    params[ 'filterProperties' ] = filter_properties if filter_properties
		    params[ 'pluginBlackList' ] = plugin_blacklist if plugin_blacklist
		    params[ 'pluginWhiteList' ] = plugin_whitelist if plugin_whitelist

		    if MobyUtil::Parameter[ sut_id ][ :filter_type,'none' ] == 'dynamic'

		      MobyUtil::DynamicAttributeFilter.instance.update_filter( caller( 0 ) ) # updates the filter with the current backtrace file list

		      white_list = attribute_filter_string = MobyUtil::DynamicAttributeFilter.instance.filter_string

		      params['attributeWhiteList'] = white_list if white_list

		    elsif MobyUtil::Parameter[ sut_id ][ :filter_type,'none' ] == 'static'

		      black_list = MobyUtil::Parameter[ sut_id ][ :attribute_blacklist, nil ]
		      white_list = MobyUtil::Parameter[ sut_id ][ :attribute_whitelist, nil ]

		      params['attributeBlackList'] = black_list if black_list
		      params['attributeWhiteList'] = white_list if white_list

		    end

		    params		

	    end

	    # enable hooking for performance measurement & debug logging
	    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	  end #module Application    

  end #module QT  

end #module MobyController
