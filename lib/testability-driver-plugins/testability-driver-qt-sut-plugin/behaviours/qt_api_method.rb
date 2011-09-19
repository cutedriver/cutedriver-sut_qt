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

		module ApiMethod

			class MethodReturnValue

				attr_reader :value, :type

				def initialize( type, value )
					raise ArgumentError.new("Invalid argument type for type. (Actual: %s, Expected: String)" % [ type.class.to_s ] ) unless type.kind_of?( String )
					raise ArgumentError.new("Invalid argument type for value. (Actual: %s, Expected: String)" % [ value.class.to_s ] ) unless value.kind_of?( String )
					@type, @value = type, value
				end
	
				def to_s
					@value
				end

				def ==( value )
					value == @value
				end

				# enable hooking for performance measurement & debug logging
				TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

			end

			class Method

				RETURN_RESULT_VALUE	= 0x01
				RETURN_RESULT_AS_LIST	= 0x02
				RETURN_RESULT_AS_XML	= 0x03
			
				def initialize( parent, fixture_name )
					raise ArgumentError.new("Invalid argument type for fixture name. (Actual: %s, Expected: String)" % [ fixture_name.class.to_s ] ) unless fixture_name.kind_of?( String )
					@parent, @fixture_name = parent, fixture_name
				end

				def list_methods
					execute( RETURN_RESULT_AS_LIST, 'list_methods' )
				end

				def list_class_methods( class_name )
					raise ArgumentError.new("Invalid argument type for class name. (Actual: %s, Expected: String)" % [ class_name.class.to_s ]) unless class_name.kind_of?( String )
					execute( RETURN_RESULT_AS_LIST, 'list_class methods', { :class => class_name } )
				end

				def method_missing( method_name, *args, &block )
					execute( RETURN_RESULT_VALUE, 'invoke_method', { :method => "#{ method_name }", :args =>  MobyUtil::FixtureParameter.new( *args ).to_s } )
				end

				def debug_invoke_method( method_name, *args )
					# call methods normally
					execute( RETURN_RESULT_AS_XML, 'invoke_method', { :method => "#{ method_name }", :args =>  MobyUtil::FixtureParameter.new( *args ).to_s } )
				end

			private

				def execute( return_result_as_mode, command, *args )

					result = nil

					@parent.fixture( @fixture_name, command, *args ).tap{ | result_xml |

						case return_result_as_mode
			
							when RETURN_RESULT_VALUE

								# return value as QtMethodReturnValue
								MobyUtil::XML.parse_string( result_xml ).tap{ | xml_data |
									xml_data.xpath( "*//object[@type='QtMethod']/attributes" ).first.tap{ | element |
										result = QtMethodReturnValue.new( 
											element.xpath( "attribute[@name='returnValueType']/value" ).first.content,
											element.xpath( "attribute[@name='returnValue']/value" ).first.content
										) unless element.nil?
									} 
								}

								raise RuntimeError.new("Unable to parse fixture result xml (QtApiAccessor)") if result.nil?

							when RETURN_RESULT_AS_LIST

								# return result as Array 
								result = []

								# TODO: This branch needs to be refactored --> method needed that retrieves ALL TestObjects of given type without MultipleTestObjectsFound exception
								MobyUtil::XML.parse_string( result_xml ).tap{ | xml_data |
									xml_data.xpath( "*//object[@type='QtMethod']" ).each{ | element |
										result << { :method => "#{ element.attribute("name") }" }
										element.xpath( "attributes/*" ).each{ | attributes |
											result.last.merge!( { attributes.attribute( "name" ).to_sym => attributes.xpath( "value" ).first.content } )
										}
									} 
								}

							when RETURN_RESULT_AS_XML
								# return result as is (xml string)
								result = result_xml

						end

					}

					result

				end

				# enable hooking for performance measurement & debug logging
				TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

			end

      # == nodoc
			def QtMethod

				MobyBehaviour::QT::ApiMethodBehaviour::Method.new( self, "tasqtapiaccessor" )

			end
		
			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
  
		end

	end

end
