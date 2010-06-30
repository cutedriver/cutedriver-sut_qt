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



module MobyCommand

	class Drag < MobyCommand::CommandData

		#attr_writer :xcoordinate, :_ycoordinate

		# Constructor to Tap
		# == params
		# text:: (optional) String to be added to text sequence if given.
		# == returns
		# Instance of TypeText
		def initialize( start_x = nil, start_y = nil, end_x = nil, end_y = nil, duration = 1 )    
			# Set status value to nil (not executed)
			@_start_x = start_x 
			@_start_y = start_y 
			@_end_x = end_x 
			@_end_y = end_y 
			@_duration = duration 
		end

	end

end #module
