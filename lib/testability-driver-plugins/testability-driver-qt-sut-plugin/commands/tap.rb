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



#require File.expand_path( File.join( File.dirname( __FILE__ ), 'command_data' ) )

module MobyCommand

	class Tap < MobyCommand::CommandData

		# Constructor to Tap
		# == params
		# text:: (optional) String to be added to text sequence if given.
		# == returns
		# Instance of TypeText
		def initialize( xcoordinate = nil, ycoordinate = nil, time_to_hold = 1, times_to_tap = 1, time_between_taps = 1 )    
			# Set status value to nil (not executed)
			@_xcoordinate = xcoordinate
			@_ycoordinate = ycoordinate
			@_time_to_hold = time_to_hold
			@_times_to_tap = times_to_tap
			@_time_between_taps = time_between_taps
		end

    def get_x
      @_xcoordinate
    end
    def get_y
      @_ycoordinate
    end
    def get_hold
      @_time_to_hold
    end

	end

end #module
