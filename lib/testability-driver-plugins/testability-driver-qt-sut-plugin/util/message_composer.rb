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

module MobyUtil

	module MessageComposer
	 
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

    def hash_to_attributes( hash )

     ( hash || {} ).collect{ | value | "#{ value.first }=\"#{ value.last }\"" }.join(" ")

    end

	  def make_xml_message( service_details, command_name, params, command_value = nil )

=begin

      # create message as string
      #MobyUtil::MessageComposer::hash_to_attributes                                         140      0.00405100      0.00405100    0.010%      0.00002894
      #MobyUtil::MessageComposer::make_xml_message                                            70      0.00762200      0.00357100    0.009%      0.00010889

      "<TasCommands #{ hash_to_attributes( service_details ) }>" <<
      "<Target TasId=\"Application\">" << 
      "<Command name=\"#{ command_name }\" #{ hash_to_attributes( params ) }#{ command_value ? ">#{ command_value }</Command>" : " />"  }" <<
      "</Target>" <<
      "</TasCommands>"

      # vs.

      # create message using builder
      #MobyUtil::MessageComposer::make_xml_message                                            70      0.03611100      0.03611100    0.090%      0.00051587

      # create message
		  MobyUtil::XML.build{
		    TasCommands( service_details ) {
			  Target( :TasId => "Application" ) {
			    Command( command_value || "", ( params || {} ).merge( :name => command_name ) )
			  }
		    }
		  }.to_xml		  

=end

      # construct xml message as string; using builder is approx. 67% slower, see statistics above
      "<TasCommands #{ hash_to_attributes( service_details ) }><Target TasId=\"Application\"><Command name=\"#{ command_name }\" #{ hash_to_attributes( params ) }#{ command_value ? ">#{ command_value }</Command>" : " />"  }</Target></TasCommands>"

	  end

	  def make_fixture_message(fixture_plugin, params)

		  Nokogiri::XML::Builder.new{
		    TasCommands( :id => params[:application_id].to_s, :service => "fixture", :async => params[:async].to_s ) {
			  Target( :TasId => params[:object_id].to_s, :type => params[:object_type].to_s ) {
			    Command( :name => "Fixture", :plugin => fixture_plugin, :method => params[:command_name].to_s ) {
				  params[:parameters].collect{ | name, value | 
				    param( :name => name, :value => value )
				  }
			    }
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
		  sut_parameters = $parameters[ @_sut.id ]

		  params[ 'filterProperties' ] = $last_parameter if sut_parameters[ :filter_properties, nil ]
		  params[ 'pluginBlackList'  ] = $last_parameter if sut_parameters[ :plugin_blacklist,  nil ]
		  params[ 'pluginWhiteList'  ] = $last_parameter if sut_parameters[ :plugin_whitelist,  nil ]

		  case sut_parameters[ :filter_type, 'none' ]
		    
		  when 'dynamic'

		    # updates the filter with the current backtrace file list
		    #MobyUtil::DynamicAttributeFilter.instance.update_filter( caller( 0 ) ) 

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
		
		  case $parameters[ @_sut.id ][ :filter_type, 'none' ]
		  when 'none' 
		    command_xml = make_xml_message( app_details, 'UiState', @_flags || {} )
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
		  arguments = $parameters[ @_sut.id ][ :application_start_arguments, "" ].clone 
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

		  make_xml_message({:service => 'startApplication'}, 'Run', parameters)				
	  end

	  def close_message
	  
	    sut_parameters = $parameters[ @_sut.id ]
	  
		  parameters = {
		    'uid' => @_application_uid, 
		    'kill' => ( @_flags || {} )[ :force_kill ] || sut_parameters[ :application_close_kill ], 
		    'wait_time' => sut_parameters[ :application_close_wait ] 		  
		  }

		  make_xml_message({:service => 'closeApplication', :id => @_application_uid }, 'Close', parameters)
	  end
	
    # enable hoo./base/test_object/factory.rb:king for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
  
	end
	
	
end

