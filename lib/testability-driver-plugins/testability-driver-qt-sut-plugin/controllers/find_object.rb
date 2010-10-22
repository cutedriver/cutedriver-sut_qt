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

	module FindObjectCommand

	  # Execute the command
	  # Sends the message to the device using the @sut_adapter (see base class)     
	  # == params         
	  # == returns
	  # == raises
	  # NotImplementedError: raised if unsupported command type       
	  def execute
		filters = make_params if MobyUtil::Parameter[ @_sut.id ][ :filter_type, 'none' ] == 'dynamic'

		params = search_parameters

		builder = Nokogiri::XML::Builder.new do |xml|
		  xml.TasCommands( ( application_details || {} ).merge( :service => "findObject") ) {			
			xml.Target{			  
			  add_objects(xml, params)
			  xml.Command( :name => 'findObject' ){
				filters.collect{ | name, value | 
				  xml.param( :name => name, :value => value ) 
				}					        
			  } if MobyUtil::Parameter[ @_sut.id ][ :filter_type, 'none' ] == 'dynamic'
			} if params and params.size > 0
		  }
		end
		msg = builder.to_xml
		#puts msg.to_s	

		@sut_adapter.send_service_request(Comms::MessageGenerator.generate(msg), true)
		
	  end

	  def set_adapter( adapter )
		@sut_adapter = adapter
	  end

	  private

	  def add_objects(builder, params)
		parent = builder.parent
		params.each{|objectParams| parent = create_object_node(builder, objectParams, parent)}			  
	  end
	  
	  def create_object_node(builder, params, parent)
		node = Nokogiri::XML::Node.new('object', builder.doc)
		params.keys.each{|key| node[key.to_s] = params[key].to_s}
		parent.add_child(node)
	  end


	  def make_params
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


	  # enable hooking for performance measurement & debug logging
	  MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end #module FindObjectCommand
	
  end #module QT

end #module MobyController

