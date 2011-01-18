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
  
  module FindObjectGenerator
	
	def generate_message
	
	  filter_type = $parameters[ @_sut.id ][ :filter_type, 'none' ]
	
	  filters = make_params if filter_type == 'dynamic'

	  builder = Nokogiri::XML::Builder.new do |xml|

		  xml.TasCommands( ( @_app_details || {} ).merge( :service => "findObject") ) {			

		    xml.Target{			  

			    add_objects( xml, @_params )

			    xml.Command( :name => 'findObject' ){ filters.collect{ | name, value | xml.param( :name => name, :value => value ) } } if filter_type == 'dynamic'

		    } if @_params and @_params.size > 0

		  }

	  end

	  builder.to_xml

	end

	private

	def add_objects( builder, params )

	  parent = builder.parent

	  params.each{| objectParams | parent = create_object_node( builder, objectParams, parent ) }

	end
	
	def create_object_node( builder, params, parent )

	  node = Nokogiri::XML::Node.new( 'object', builder.doc )

	  params.keys.each{ | key | node[ key.to_s ] = params[ key ].to_s }

	  parent.add_child( node )

	end


	def make_params
	
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

    # enable hoo./base/test_object/factory.rb:king for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end
  
end
