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

	class FixtureParameter

		attr_accessor :parameters

		def initialize( *args )
			@parameters = []
			# accept array as multiple arguments, hash for one argument
			args = [ [ args.first ] ] if args.size == 1 && args.first.kind_of?( Hash )
			args.each{ | argument | add_parameter( argument.first )	} 
		end

		def add_parameter( hash )

			raise ArgumentError.new("Argument :value and :type must be defined. Actual hash: #{ hash.inspect }") unless hash.has_key?( :type ) and hash.has_key?( :value )

			@parameters.push( hash )

		end

		def remove_parameter( index_or_range )
 
			# value can be range or index, or array of ranges or indexes
			@parameters.slice!( index_or_range )

		end

		def list_parameters

			return @parameters.inspect

		end
	
		def to_s

			Nokogiri::XML::Builder.new{

				fixture_parameters{

					parameters.each_index{ | index | 

						parameter( parameters[index].merge( :id => index) )

					}

				}

			}.to_xml

		end

	end

end

