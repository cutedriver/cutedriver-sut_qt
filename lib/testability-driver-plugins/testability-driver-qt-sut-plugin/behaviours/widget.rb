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



# TODO: document 
module MobyBehaviour

	module QT

		module Widget

			include MobyBehaviour::QT::Behaviour

			# Moves the mouse to the object it was called on.
			# == params
			# refresh::(optional) if true will cause the framework to refresh the ui state. Default is false.
			# === examples
			# @object.move_mouse
			def move_mouse( move_params = false )

        $stderr.puts "#{ caller(0).last.to_s } warning: move_mouse(boolean) is deprecated; use move_mouse(Hash)" if move_params == true

				begin    
          # Hide all future params in a hash
          use_tap_screen = false
          if move_params.kind_of? Hash
            use_tap_screen = move_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
              move_params[:use_tap_screen].to_s
          else
            use_tap_screen = MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false']
          end
					command = command_params #in qt_behaviour           
					command.command_name('MouseMove')

          if attribute('objectType') == 'Web' or attribute('objectType') == 'Embedded'
					  params = {'x' => center_x, 'y' => center_y, 'useCoordinates' => 'true', 
            'useTapScreen' => use_tap_screen}
          else 
					  params = {'useTapScreen' => use_tap_screen.to_s}
					end
          command.command_params(params)

					@sut.execute_command(command)    

				rescue Exception => e      

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to mouse_move"
					Kernel::raise e        
				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation mouse_move executed successfully"
        
				nil

			end

			# Taps the screen on the coordinates of the object.
			# == params
			# tap_count::(optional defaults to 1)number of times to tap the screen
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle 
			# x::(optional defaults to nil) x coordinate inside object to click, if nil then center is used
			# y::(optional defaults to nil) y coordinate inside object to click, if nil then center is used
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button type is given
			# ArgumentError:: If coordinates are outside of the object
			# === examples
			#  @object.tap  
      #			def tap( tap_count = 1, interval = nil, button = :Left) 
      #			def tap( tap_count = 1, interval = nil, button = :Left, tap_screen = false, duration = 0.1 )   
			def tap( tap_params = 1, interval = nil, button = :Left )
				begin   
				  #for api compatibility
				  if interval and interval.kind_of?(Symbol)
            button = interval 
            interval = nil
				  end
				  
          # Another one, first param a has for the rest
          if tap_params.kind_of?(Hash)
            interval = tap_params[:interval]
            if tap_params[:button].nil? 
              button = :Left
            else
              button = tap_params[:button]
            end

            tap_count = tap_params[:tap_count].nil? ? 1 : tap_params[:tap_count]
            duration = tap_params[:duration]
            if duration.nil?
              duration = 0.1
            end
            use_tap_screen = tap_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
              tap_params[:use_tap_screen].to_s
          else
            tap_count = tap_params
            duration = 0.1
            use_tap_screen = MobyUtil::Parameter[@sut.id][ :use_tap_screen, 'false']            
          end

          raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(button)	    
          if interval 
            raise ArgumentError.new( "Invalid interval must be an integer." ) unless interval.kind_of?(Integer)
          end
          
          command = command_params #in qt_behaviour           
          command.command_name('Tap')
          
          params = {
            'count' => tap_count.to_s, 
            'button' => @@_buttons_map[button], 
            'mouseMove' => MobyUtil::Parameter[ @sut.id ][ :in_tap_move_pointer, 'false' ], 
            'useTapScreen' => use_tap_screen, 
            'duration' => duration.to_s
          }     


          if interval
            params[:interval] = (interval.to_f * 1000).to_i					
          end

          if attribute('objectType') == 'Web' or attribute('objectType') == 'Embedded'
            params['x'] = center_x
            params['y'] = center_y					
            params['useCoordinates'] = 'true'
          end
          command.command_params(params)
          
          @sut.execute_command( command )    				

          #do not allow operations to continue untill taps done
          if interval
            sleep interval * tap_count
          end
          
        rescue Exception => e      

          MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed tap with tap_count \"#{tap_count}\", button \"#{button.to_s}\".;#{identity};tap;"
          Kernel::raise e        

        end      

        MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation tap executed successfully with tap_count \"#{tap_count}\", button \"#{button.to_s}\".;#{identity};tap;"
        
        nil

      end

			# Taps the screen on the specified coordinates of the object. Given coordinates are relative to the object.
			# == params  
			# x::x coordinate inside object to click 
			# y::y coordinate inside object to click
			# tap_count::(optional defaults to 1)number of times to tap the screen
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle 
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen  
			# ArgumentError:: If coordinates are outside of the object
			# === examples
			#  @object.tap_object(5, 5)    
			def tap_object( x, y, tap_count = 1, button = :Left, tap_params = nil )

				begin
          # New hash format for the parameter. Also incorporates all
          # previous tap_object_* commands that were redundant.
          if tap_params.kind_of? Hash
            command_name = tap_params[:command].nil? ? 'Tap' : tap_params[:command]
            behavior_name = tap_params[:behavior_name].nil? ? 'tap_object' : tap_params[:behavior_name]

            use_tap_screen = tap_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
              tap_params[:use_tap_screen].to_s
          else
            use_tap_screen = MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false']
            command_name = 'Tap'
            behavior_name = 'tap_object'
          end
          
					raise ArgumentError.new( "Coordinate x:#{x} x_abs:#{x} outside object." ) unless ( x <= attribute( 'width' ).to_i and x >= 0 )
					raise ArgumentError.new( "Coordinate y:#{y} y_abs:#{y} outside object." ) unless ( y <= attribute( 'height' ).to_i and y >= 0 )

					command = command_params #in qt_behaviour
					command.command_name(command_name)

          

					command.command_params(
                                 'x' => ( attribute('x_absolute').to_i + x.to_i ).to_s, 
                                 'y' => ( attribute('y_absolute').to_i + y.to_i ).to_s, 
                                 'count' => tap_count.to_s, 
                                 'button' => @@_buttons_map[ button ], 
                                 'mouseMove' => MobyUtil::Parameter[ @sut.id ][ :in_tap_move_pointer, 'false' ],
                                 'useCoordinates' => 'true',
                                 'useTapScreen' => use_tap_screen
                                 )

					@sut.execute_command(command)			

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed #{behavior_name} with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};#{behavior_name};"
					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation #{behavior_name} executed successfully with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};#{behavior_name};"

				nil

			end

			# Tap down on the screen on the specified coordinates of the object. Given coordinates are relative to the object.
			# == params  
			# x::x coordinate inside object
			# y::y coordinate inside object
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle 
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen  
			# ArgumentError:: If coordinates are outside of the object
			# === examples
			#  @object.tap_down_object(5, 5)    
			def tap_down_object( x, y, button = :Left, tap_params = {} )        
        tap_params[:behavior_name] = 'tap_down_object'
        tap_params[:command] = 'MousePress'
        tap_object(x,y,1,button,tap_params)
			end

			# Tap up on the screen on the specified coordinates of the object. Given coordinates are relative to the object.
			# == params  
			# x::x coordinate inside object
			# y::y coordinate inside object
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle 
      # tap_params::(optional, defautlts to Hash} Hash consisting of any additional parameter.
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen  
			# ArgumentError:: If coordinates are outside of the object
			# === examples
			#  @object.tap_up_object(5, 5)    
			def tap_up_object( x, y = -1, button = :Left, tap_params = {} )
        tap_params[:behavior_name] = 'tap_up_object'
        tap_params[:command] = 'MouseRelease'
        tap_object(x,y,1,button,tap_params)
			end

			# Taps the screen on the coordinates of the object for the period of time given is seconds.
			# == params
			# time::(optional defaults to 1) number of seconds to hold the pointer down. 
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle 
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button type is given
			# === examples
			#  @object.long_tap(2, :Left)
			def long_tap( time = 1, button = :Left, tap_params = {} )

        logging_enabled = MobyUtil::Logger.instance.enabled
        MobyUtil::Logger.instance.enabled = false


        raise ArgumentError.new("First parameter should be time between taps or Hash") unless tap_params.kind_of? Hash or tap_params.kind_of? Fixnum
        

			  begin
			    tap_down(button, false, tap_params)
          sleep time
          tap_up(button, false, tap_params)
			  rescue Exception => e
			    MobyUtil::Logger.instance.enabled = logging_enabled      
          MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed long_tap with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_tap;"
          Kernel::raise e

			  end      
        MobyUtil::Logger.instance.enabled = logging_enabled
			  MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation long_tap executed successfully with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_tap;"

			  nil

      end

			# Long tap on the screen on the given relative coordinates of the object for the period of time given is seconds.
			# == params
			# x::x coordinate inside object
			# y::y coordinate inside object
			# time::(optional defaults to 1) number of seconds to hold the pointer down. 
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle 
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button type is given
			# === examples
			#  @object.long_tap_object(1, 2, 1, :Left)
			def long_tap_object( x, y, time = 1, button = :Left, tap_params = {} )

				begin
					tap_down_object(x, y, button, tap_params)
					sleep time
					tap_up_object(x, y, button, tap_params)				
				rescue Exception => e
          
					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed long_tap_object with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_tap_object;"
					Kernel::raise e

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation long_tap_object executed successfully with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_tap_object;"

				nil

			end

			# Tap down the screen on the coordinates of the object
			# == params
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			# refresh::(optional) If false ui state will not be updated 
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button type is given
			# === examples
			#  @object.long_tap_down
			def tap_down( button = :Left, refresh = false, tap_params = {} )

				begin
          use_tap_screen = tap_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            tap_params[:use_tap_screen].to_s
          tap_params[:useTapScreen] = use_tap_screen

					raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(button)  	
					command = command_params #in qt_behaviour           
					command.command_name('MousePress')

          params = {'button' => @@_buttons_map[button],
            'mouseMove' => MobyUtil::Parameter[ @sut.id ][ :in_tap_move_pointer, 'false' ], 
            'useTapScreen' => use_tap_screen}

          if attribute('objectType') == 'Web' or attribute('objectType') == 'Embedded'
					  params['x'] = center_x
					  params['y'] = center_y					
					  params['useCoordinates'] = 'true'
					end
          params.merge!(tap_params)

          command.command_params(params)
					@sut.execute_command(command)

					self.force_refresh( :id => get_application_id ) if refresh

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed tap_down with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};tap_down;"
					Kernel::raise e

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation tap_down executed successfully with with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};tap_down;"

				nil

			end

			# Release the pointer on the screen on the coordinates of the object
			# == params
			# button::(optional defaults to :Left) button symbol supported values are: :NoButton, :Left, :Right, :Middle
			# refresh::(optional) If false ui state will not be updated 
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button type is given
			# === examples
			#  @object.tap_up
			def tap_up( button = :Left, refresh = true, tap_params = {} )    

				begin
          use_tap_screen = tap_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            tap_params[:use_tap_screen].to_s
          tap_params[:useTapScreen] = use_tap_screen

					raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(button)
					command = command_params #in qt_behaviour           
					command.command_name('MouseRelease')
          params = {'button' => @@_buttons_map[button], 'useTapScreen' => use_tap_screen}

          if attribute('objectType') == 'Web' or attribute('objectType') == 'Embedded'
					  params['x'] = center_x
					  params['y'] = center_y					
					  params['useCoordinates'] = 'true'
					end
          params.merge!(tap_params)

          command.command_params(params)


					@sut.execute_command(command)
					self.force_refresh({:id => get_application_id}) if refresh

				rescue Exception => e
          
					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed tap_up with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};tap_up;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation tap_up executed successfully with with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};tap_up;"

				nil

			end

			# TODO: [2009-04-02] Remove deprevated methods?

			# warning: TestObject#press is deprecated; use TestObject#tap
			def press( tap_count = 1, button = :Left )

				$stderr.puts "#{ caller(0).last.to_s } warning: TestObject#press is deprecated; use TestObject#tap"

				begin 
					raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(button)

					command = command_params #in qt_behaviour           

					command.command_name('Tap')

					command.command_params(
                                 'x' => center_x, 
                                 'y' => center_y, 
                                 'count' => tap_count.to_s, 
                                 'button' => @@_buttons_map[button], 
                                 'mouseMove'=>'true'
                                 )

					@sut.execute_command(command)    				

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed press with tap_count \"#{tap_count}\", button \"#{button.to_s}\".;#{identity};press;"
					Kernel::raise e        

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation press executed successfully with tap_count \"#{tap_count}\", button \"#{button.to_s}\".;#{identity};press;"

				nil

			end

			# TestObject#long_press is deprecated; use TestObject#long_tap
			def long_press( time = 1, button = :Left )

				$stderr.puts "#{ caller(0).last.to_s } warning: TestObject#long_press is deprecated; use TestObject#long_tap"			

				begin
					long_tap(time, button)
				rescue Exception => e      
					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed long_press with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_press;"
					Kernel::raise e        
				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation long_press executed successfully with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_press;"
        
				nil

			end

			# TestObject#hold is deprecated; use TestObject#tap_down
			def hold(button = :Left, refresh = true)

				$stderr.puts "#{ caller(0).last.to_s } warning: TestObject#hold is deprecated; use TestObject#tap_down"

				begin

					tap_down(button, refresh)

				rescue Exception => e      

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed hold with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};hold;"
					Kernel::raise e        

				end
	      
				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation hold executed successfully with with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};hold;"
        
				nil

			end

			# TestObject#release is deprecated; use TestObject#tap_up
			def release( button = :Left, refresh = true )

				$stderr.puts "#{ caller(0).last.to_s } warning: TestObject#release is deprecated; use TestObject#tap_up"

				begin

					tap_up(button, refresh)

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed release with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};release;"
					Kernel::raise e

				end      

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation release executed successfully with with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};release;"
        
				nil

			end

=begin    
         private 

         def center_x
           x = self.attribute('x_absolute').to_i
           width = self.attribute('width').to_i
           x = x + (width/2)
           x.to_s
         end

         def center_y
           y = self.attribute('y_absolute').to_i
           height = self.attribute('height').to_i
           y = y + (height/2)
           y.to_s
         end  
=end  
     end # Widget


   end # QT

 end # MobyBehaviour

 MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Widget )
