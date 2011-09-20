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

# Find behaviours 
#
# Methods for finding test objects on the suttest objet state
module MobyBehaviour

	module QT
 
    # == description
    # Defines methods to find test objects and scroll them to the display
    #
    # == behaviour
    # QtFind
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # *
    #
    # == sut_type
    # qt
    #
    # == sut_version
    # *
    #
    # == objects
    # *
    #
		module Find   
			include MobyBehaviour::QT::Behaviour
			
			# == nodoc
			# TODO: fix this
			def find_and_center (find_hash = {})
			  begin
				search_result = find(find_hash)
				
				## Calculate Center
				myWindow = search_result.sut.application.find(:parent => 0, :isWindow => "true") # throws multiple found exeptions
				window_width = myWindow.attribute('width').to_i/2
				window_height = myWindow.attribute('height').to_i/2
				window_x = myWindow.attribute('x_absolute').to_i + window_width.to_i
				window_y = myWindow.attribute('y_absolute').to_i + window_height.to_i
				
				## flick_to (center)
				search_result.flick_to(window_x.to_i, window_y.to_i)
			  rescue Exception => e
				##$logger.behaviour "FAIL;Failed to find test object.;#{id.to_s};sut;{};find;" << (find_hash.kind_of?(Hash) ? find_hash.inspect : find_hash.class.to_s)  
				## Rescue from center and flick
				raise e
			  end
			  $logger.behaviour "PASS;Test object found and centered.;#{id.to_s};sut;{};application;" << find_hash.inspect  
			  search_result
			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
			
		end # module Find
	
	end # module QT
	
end # module MobyBehaviour
