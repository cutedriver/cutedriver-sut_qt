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
    
      # get sut paramteres only once, store to local variable
      sut_parameters = $parameters[ @_sut.id ]

	    filter_type = sut_parameters[ :filter_type, 'none' ]
	
      plugin_timeout = sut_parameters[ :qttas_plugin_timeout, 10000 ].to_i
      
	    if filter_type != 'none'

	      filters = {}

        sut_parameters.if_found( :filter_properties ){ | key, value | filters[ 'filterProperties' ] = value }
        sut_parameters.if_found( :plugin_blacklist  ){ | key, value | filters[ 'pluginBlackList'  ] = value }
        sut_parameters.if_found( :plugin_whitelist  ){ | key, value | filters[ 'pluginWhiteList'  ] = value }
        sut_parameters.if_found( :use_view_crop     ){ | key, value | filters[ 'useViewCrop'      ] = value }

	      case filter_type
		
	        when 'dynamic'
		
            value = TDriver::AttributeFilter.filter_string

		        filters[ 'attributeWhiteList' ] = value unless value.blank?

	        when 'static'
		
            sut_parameters.if_found( :attribute_blacklist ){ | key, value | filters[ 'attributeBlackList' ] = value }
            sut_parameters.if_found( :attribute_whitelist ){ | key, value | filters[ 'attributeWhiteList' ] = value }

	        end

      else

        filters = {}

      end

      #xml = "<?xml version=\"1.0\"?>"

      xml = "<TasCommands plugin_timeout=\"#{plugin_timeout}\" service=\"findObject\" #{ @_app_details.to_attributes }"

      # pass checksum value if known from previous service request result
      #unless @_checksum.nil?
      #  xml << " checksum=\"#{ @_checksum.to_s }\" "
      #end

      unless @_params.empty?

        # TasCommands close    
        xml << '><Target>'
        
        # temp. objects xml fragment
        objects = ""

        # collect objects with attributes
        @_params.reverse_each{ | parameters |
        
          if parameters == @_params.last
          
            objects = "<object #{ parameters.to_attributes } />"          
            
          else
          
            objects = "<object #{ parameters.to_attributes }>#{ objects }</object>"
            
          end
        
        }

        # add objects to xml
        xml << objects

        xml << '<Command name="findObject">'

        filters.each{ | name, value | xml << "<param name=\"#{ name }\" value=\"#{ value }\" />" }

        xml << '</Command></Target></TasCommands>'
    
      else
    
        # TasCommands close
        xml << ' />'
      
      end
      
      xml

    end

=begin	
    def generate_message
    
      # get sut paramteres only once, store to local variable
      sut_parameters = $parameters[ @_sut.id ]

	    filter_type = sut_parameters[ :filter_type, 'none' ]
	
	    if filter_type != 'none'

	      filters = {}
	      value = nil
	      filters[ 'filterProperties' ] = value if ( value = sut_parameters[ :filter_properties, nil ] )
	      filters[ 'pluginBlackList'  ] = value if ( value = sut_parameters[ :plugin_blacklist,  nil ] )
	      filters[ 'pluginWhiteList'  ] = value if ( value = sut_parameters[ :plugin_whitelist,  nil ] )

	      case filter_type
		
	        when 'dynamic'

		        filters[ 'attributeWhiteList' ] = value if ( value = TDriver::AttributeFilter.filter_string ) 
		
	        when 'static'

		        filters[ 'attributeBlackList' ] = value if ( value = sut_parameters[ :attribute_blacklist, nil ] )
		        filters[ 'attributeWhiteList' ] = value if ( value = sut_parameters[ :attribute_whitelist, nil ] ) 
		
	        end

      else

        filters = {}

      end

      #xml = "<?xml version=\"1.0\"?>"

      xml = "<TasCommands service=\"findObject\" #{ @_app_details.to_attributes }"
      
      unless @_params.empty?

        # TasCommands close    
        xml << '><Target>'
        
        # temp. objects xml fragment
        objects = ""

        # collect objects with attributes
        @_params.reverse.each_with_index{ | parameters, index |
        
          if index == 0
          
            objects = "<object #{ parameters.to_attributes } />"          
            
          else
          
            objects = "<object #{ parameters.to_attributes }>#{ objects }</object>"
            
          end
        
        }

        # add objects to xml
        xml << objects

        xml << '<Command name="findObject">'

        filters.each{ | name, value | xml << "<param name=\"#{ name }\" value=\"#{ value }\" />" }

        xml << '</Command></Target></TasCommands>'
    
      else
    
        # TasCommands close
        xml << ' />'
      
      end
      
      xml

    end
=end

=begin	
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

	    params.each{| objectParams | 
	    
	      parent = create_object_node( builder, objectParams, parent ) 
	      
      }

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

		      white_list = TDriver::AttributeFilter.filter_string
		      
		      params['attributeWhiteList'] = white_list if white_list
		
	      when 'static'

		      params['attributeBlackList'] = $last_parameter if sut_parameters[ :attribute_blacklist, nil ]
		      params['attributeWhiteList'] = $last_parameter if sut_parameters[ :attribute_whitelist, nil ]
		
      end

      params		

    end
=end

    # enable hoo./base/test_object/factory.rb:king for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end
  
end

