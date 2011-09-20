############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of TDriver. 
## 
## If you have questions regarding the use of this file, please contact 
## Nokia at testabilitydriver@nokia.com. 
## 
## This library is free software; you can redistribute it and/or 
## modify it under the terms of the GNU Lesser General Public 
## License version 2.1 as published by the Free Software Foundation 
## and appearing in the file LICENSE.LGPL included in the packaging 
## of this file. 
## 
############################################################################


module MobyUtil

	class Widget

         # Common method, tap up or down
    def self.tap_updown_object(tap_params, y, button, identity, command_name)
       begin
         behavior_name = command_name == 'MousePress' ? 'tap_down_object' : 'tap_up_object'
         if tap_params.kind_of? Hash
           x = tap_params[:x].nil? ?  -1 : tap_params[:x]
           y = tap_params[:y].nil? ? -1 : tap_params[:y]
           button = tap_params[:button].nil? ? (:Left) : tap_params[:button]
           use_tap_screen = tap_params[:use_tap_screen] == true ? 'true' : 
             $parameters[ @sut.id][ :use_tap_screen, 'false']
         else
           x = tap_params
           use_tap_screen = $parameters[ @sut.id ][ :use_tap_screen, 'false' ]
         end

         raise ArgumentError.new( "Coordinate x:#{x} x_abs:#{x} outside object." ) unless (x <= attribute('width').to_i and x >= 0)
         raise ArgumentError.new( "Coordinate y:#{y} y_abs:#{y} outside object." ) unless (y <= attribute('height').to_i and y >= 0)

         command = command_params #in qt_behaviour
         command.command_name(command_name)

         x_tap = attribute('x_absolute').to_i + x.to_i
         y_tap = attribute('y_absolute').to_i + y.to_i

         mouse_move = @sut.parameter[:in_tap_move_pointer]
         mouse_move = 'false' unless mouse_move

         params = { 'x'=>x_tap.to_s, 'y' => y_tap.to_s, 'button' => @@_buttons_map[button], 'mouseMove'=>mouse_move }
         # use coordinates
         params['useCoordinates'] = 'true'
         params['useTapScreen'] = use_tap_screen
         command.command_params(params)

         @sut.execute_command(command)			

       rescue Exception => e

         $logger.behaviour "FAIL;Failed #{behavior_name} with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};#{behavior_name};"
         raise e

       end

       $logger.behaviour "PASS;Operation #{behavior_name} executed successfully with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};#{behavior_name};"

       nil


       
     end
     

	end

end

