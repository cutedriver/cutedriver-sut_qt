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

    # == description
    # Widget specific behaviours
    #
    # == behaviour
    # QtWidget
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # touch
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
    module Widget

      include MobyBehaviour::QT::Behaviour

      # == description
      # Moves the mouse to the object it was called on.
      # == arguments
      # move_params
      #  Boolean
      #   description: if true will cause the framework to refresh the UI state
      #   example: true
      # == returns
      # NilClass
      #  description: -
      #  example: -
      # == examples
      # @object.move_mouse
      def move_mouse( move_params = false )

        $stderr.puts "#{ caller(0).last.to_s } warning: move_mouse(boolean) is deprecated; use move_mouse(Hash)" if move_params == true

        begin
          # Hide all future params in a hash
          use_tap_screen = false
          if move_params.kind_of? Hash
            use_tap_screen = move_params[:use_tap_screen].nil? ? sut_parameters[ :use_tap_screen, 'false'] : move_params[:use_tap_screen].to_s
          else
            use_tap_screen = sut_parameters[ :use_tap_screen, 'false']
          end
          command = command_params #in qt_behaviour
          command.command_name('MouseMove')

          if attribute('objectType') == 'Web' or attribute('objectType') == 'Embedded'
            params = {
              'x' => center_x, 
              'y' => center_y, 
              'useCoordinates' => 'true',
              'useTapScreen' => use_tap_screen,
              'x_off' => sut_parameters[:tap_x_offset , '0' ],
              'y_off' => sut_parameters[:tap_y_offset , '0' ]
            }
          else
            params = {'useTapScreen' => use_tap_screen.to_s}
          end
          command.command_params(params)

          execute_behavior(move_params, command)

        rescue Exception

          $logger.behaviour "FAIL;Failed to mouse_move"

          raise

        end

        $logger.behaviour "PASS;Operation mouse_move executed successfully"

        nil

      end

      # == description
      # Taps the screen on the coordinates of the object.
      #
      # == arguments
      # tap_params
      #  Hash
      #   description: arguments hash, see table below. If integer instead of a Hash, then this has deprecated meaning tap_count, which is also why default value is a number.
      #   example: -
      # interval
      #  Integer
      #   description: DEPRECATED, use hash key :interval instead
      #   example: -
      # button
      #  Symbol
      #   description: DEPRECATED, use hash key :button instead
      #   example: -
      #
      # == tables
      # tap_params_table
      #  title: Hash argument tap_params
      #  description: Valid keys for argument tap_params as hash
      #  |Key|Description|Type|Example|Default|
      #  |:button|Button to use for tapping|Symbol|:Right|:Left|
      #  |:duration|Duration in seconds for a single left button press, all other arguments ignored|Numeric|0.1|-|
      #  |:interval|This method sleeps tap_count times interval|Integer|2|1|
      #  |:tap_count|Number of taps to do|Integer|2|1|
      #  |:use_tap_screen|Should tapping be done on screen or as mouse event to the object|Boolean|true|see TDriver parameters table below|
      #  |:ensure_event|Verify that an event is sent to the target object. Retry if not received by target|Boolean|true|false|
      #
      # tdriver_params_table
      #  title: Default values read from tdriver parameters
      #  description: These setting values are read from tdriver_parameters.xml
      #  |Name|Description|Default if missing from parameters|
      #  |use_tap_screen|See :use_tap_screen above|false|
      #  |in_tap_move_pointer|Wether to actually move mouse pointer to tap coordinates|false|
      #  |:ensure_event|Verify that an event is sent to the target object. Retry if not received by target|false|
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      # == exceptions
      # TestObjectNotFoundError
      #  description: object is not visible on screen
      # ArgumentError
      #   description: Invalid button or non-integer interval
      def tap( tap_params = 1, interval = nil, button = :Left )
        # tapMeasure = Time.now
        # puts "tap: " + (Time.now - tapMeasure).to_s + " s - tap start"

        # delegate duration taps to grouped behaviors
        if tap_params.kind_of?(Hash) && !tap_params[:duration].nil?
          @sut.group_behaviours(tap_params[:duration], get_application) {
            tap_down
            tap_up
          }
          return
        end

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
            use_tap_screen = tap_params[:use_tap_screen].nil? ? sut_parameters[ :use_tap_screen, 'false'] : tap_params[:use_tap_screen].to_s
            
          else
            tap_count = tap_params

            use_tap_screen = sut_parameters[ :use_tap_screen, 'false']
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
            'mouseMove' => sut_parameters[ :in_tap_move_pointer, 'false' ],
            'useTapScreen' => use_tap_screen,
            'x_off' => sut_parameters[:tap_x_offset , '0' ],
            'y_off' => sut_parameters[:tap_y_offset , '0' ]
          }


          if interval
            params[:interval] = (interval.to_f * 1000).to_i
          end

          # puts "tap: " + (Time.now - tapMeasure).to_s + " s - before webs"

          if attribute('objectType') == 'Web' or attribute('objectType') == 'Embedded'
            #params['obj_x'] = (center_x.to_i - 1).to_s
            #params['obj_y'] = (center_y.to_i - 1).to_s
            params['x'] = (center_x.to_i - 1).to_s
            params['y'] = (center_y.to_i - 5).to_s #make sure we do not tap between two line links
            params['useCoordinates'] = 'true'
				end

          # puts "tap: " + (Time.now - tapMeasure).to_s + " s - before 2 webs"

          if(attribute('objectType') == 'Web')
            #check that type is not QWebFrame and that QWebFrame is found for object
            if type != "QWebFrame" and attributes.key?('webFrame')
              # puts "tap: " + (Time.now - tapMeasure).to_s + " s - Not q webframe"
              elemens_xml_data, unused_rule = @test_object_adapter.get_objects( @sut.xml_data, { :id => attribute('webFrame')}, true )
              object_xml_data = elemens_xml_data[0]
              object_attributes = @test_object_adapter.test_object_attributes(object_xml_data)
              x_absolute = object_attributes['x_absolute'].to_i 
              y_absolute = object_attributes['y_absolute'].to_i
              width = object_attributes['width'].to_i 
              height = object_attributes['height'].to_i  
              horizontalScrollBarHeight =  object_attributes['horizontalScrollBarHeight'].to_i
              verticalScrollBarWidth = object_attributes['verticalScrollBarWidth'].to_i

              # puts "tap: " + (Time.now - tapMeasure).to_s + " s - x_a(#{x_absolute}), y_a(#{y_absolute}), w(#{width}), h(#{height})"


              if(object_attributes['baseUrl'] != "" and (
                   (center_x.to_i < x_absolute) or
                   (center_x.to_i > x_absolute + width - verticalScrollBarWidth) or
                   (center_y.to_i < y_absolute) or
                   (center_y.to_i > y_absolute + height - horizontalScrollBarHeight)
                 )
                )
                #puts "web element scroll"
                scroll(0,0,1) # enable tap centralization
                #puts "web element force refresh in tap"
                force_refresh({:id => get_application_id})
                tap(tap_params, interval, button)
                return
              end
            end
          end
          command.command_params(params)

          # puts "tap: " + (Time.now - tapMeasure).to_s + " s - tap about to execute "
          execute_behavior(tap_params, command)

          # puts "tap: " + (Time.now - tapMeasure).to_s + " s - executed"
          #do not allow operations to continue untill taps done
          if interval
            sleep interval * tap_count
          end

        rescue Exception

          $logger.behaviour "FAIL;Failed tap with tap_count \"#{tap_count}\", button \"#{button.to_s}\".;#{identity};tap;"

          raise

        end

        $logger.behaviour "PASS;Operation tap executed successfully with tap_count \"#{tap_count}\", button \"#{button.to_s}\".;#{identity};tap;"

        # puts "tap: " + (Time.now - tapMeasure).to_s + " s - tapping ending"


        nil

      end


      # == description
      # Taps the screen on the specified coordinates of the object. Given coordinates are relative to the object.
      #
      # == arguments
      # x
      #  Integer
      #   description: x coordinate inside object to click
      #   example: 5
      #
      # y
      #  Integer
      #   description: y coordinate inside object to click
      #   example: 5
      #
      # tap_count
      #  Integer
      #   description: number of times to tap the screen
      #   example: 1
      #
      # button
      #  Symbol
      #   description: button symbol supported values are: :NoButton, :Left, :Right, :Middle
      #   example: :Left
      #
      # tap_params
      #  Hash
      #   description: parameter that also incorporate all previous tap_object_* commands :command, :behavior_name and :use_tap_screen
      #   example: { }
      #
      # == returns
      # NilClass
      #  description: -
      #  example: nil
      #
      # == exceptions
      # TestObjectNotFoundError
      #  description: If a graphics item is not visible on screen
      #
      # ArgumentError
      #  description: If coordinates are outside of the object
      #
      def tap_object( x, y, tap_count = 1, button = :Left, tap_params = nil )

        begin

          # New hash format for the parameter. Also incorporates all
          # previous tap_object_* commands that were redundant.
          if tap_params.kind_of? Hash
            command_name = tap_params[:command].nil? ? 'Tap' : tap_params[:command]
            behavior_name = tap_params[:behavior_name].nil? ? 'tap_object' : tap_params[:behavior_name]

            use_tap_screen = tap_params[:use_tap_screen].nil? ? sut_parameters[ :use_tap_screen, 'false'] : tap_params[:use_tap_screen].to_s
          else
            use_tap_screen = sut_parameters[ :use_tap_screen, 'false']
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
                                 'mouseMove' => sut_parameters[ :in_tap_move_pointer, 'false' ],
                                 'useCoordinates' => 'true',
                                 'useTapScreen' => use_tap_screen,
                                 'x_off' => sut_parameters[:tap_x_offset , '0' ],
                                 'y_off' => sut_parameters[:tap_y_offset , '0' ]
                                 
                                 )

          execute_behavior(tap_params, command)

        rescue Exception

          $logger.behaviour "FAIL;Failed #{behavior_name} with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};#{behavior_name};"

          raise

        end

        $logger.behaviour "PASS;Operation #{behavior_name} executed successfully with x \"#{x}\", y \"#{y}\", button \"#{button.to_s}\".;#{identity};#{behavior_name};"

        nil

      end


      # == description
      # Tap down the screen on the specified coordinates of the object. TBA link to generic information about tapping, options read from TDriver parameters etc.
      #
      # == arguments
      # x
      #  Integer
      #   description: X-coordinate inside the object
      #   example: 10
      # y
      #  Integer
      #   description: Y-coordinate inside the object
      #   example: 11
      # button
      #  Symbol
      #   description: button to tap down
      #   example: :Right
      # tap_params
      #  Hash
      #   description: arguments, link to table TBA
      #   example: -
      #
      # == returns
      # NilClass
      #   description: -
      #   example: nil
      #
      # == exceptions
      # Exception
      #  description: see tap_object method for exceptions
      def tap_down_object( x, y, button = :Left, tap_params = {} )
        tap_params[:behavior_name] = 'tap_down_object'
        tap_params[:command] = 'MousePress'
        tap_object(x,y,1,button,tap_params)
      end

      # == description
      # Release mouse tap on the specified coordinates of the object. TBA link to generic information about tapping, options read from TDriver parameters etc.
      #
      # == arguments
      # x
      #  Integer
      #   description: X-coordinate inside the object
      #   example: 10
      # y
      #  Integer
      #   description: Y-coordinate inside the object
      #   example: 11
      # button
      #  Symbol
      #   description: button to tap up
      #   example: :Right
      # tap_params
      #  Hash
      #   description: arguments, link to table TBA
      #   example: -
      #
      # == returns
      # NilClass
      #   description: -
      #   example: nil
      #
      # == exceptions
      # Exception
      #  description: see tap_object method for exceptions
      def tap_up_object( x, y = -1, button = :Left, tap_params = {} )
        tap_params[:behavior_name] = 'tap_up_object'
        tap_params[:command] = 'MouseRelease'
        tap_object(x,y,1,button,tap_params)
      end
      
      # == description
      # Taps the screen on the coordinates of the object for the period of time given is seconds.
      # 
      # == arguments
      # time
      #  Integer
      #   description: Number of seconds to hold the pointer down.
      #   example: 5
      #   default: 1
      #
      # button
      #  Symbol
      #   description: Button symbol supported values are: :NoButton, :Left, :Right, :Middle .
      #   example: :Right
      #   default: :Left
      #
      # tap_params
      #  Hash
      #   description: Hash with additional tap parameters. Link to table TBA
      #   example: {:behavior_name => 'long_tap', :use_tap_screen => true}
      #   default: {}
      #
      # == returns
      # NilClass
      #  description: -
      #  example: -
      #
      # == exceptions
      # ArgumentError
      #  description: If tap_params is not a Hash or a Fixnum type
      #      
      def long_tap( time = 1, button = :Left, tap_params = {} )

        logging_enabled = $logger.enabled
        $logger.enabled = false
          
        raise ArgumentError.new("First parameter should be time between taps or Hash") unless tap_params.kind_of? Hash or tap_params.kind_of? Fixnum

        begin
          ens = param_set_configured?(tap_params, :ensure_event)
          tap_params[:ensure_event] = false
          if ens
            ensure_event(:retry_timeout => 5, :retry_interval => 0.5) {
                  tap_down(button, false, tap_params)
                  sleep time
                  tap_up(button, false, tap_params)
                }
          else
            tap_down(button, false, tap_params)
            sleep time
            tap_up(button, false, tap_params)
          end

            
        rescue Exception

          $logger.enabled = logging_enabled

          $logger.behaviour "FAIL;Failed long_tap with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_tap;"

          raise

        end
        $logger.enabled = logging_enabled
        $logger.behaviour "PASS;Operation long_tap executed successfully with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_tap;"

        nil

      end

      # == description
      # Long tap on the screen on the given relative coordinates of the object for the period of time given is seconds.
      # 
      # == arguments
      # x
      #  Integer
      #   description: X-coordinate inside the object
      #   example: 10
      # y
      #  Integer
      #   description: Y-coordinate inside the object
      #   example: 11  
      #
      # time
      #  Integer
      #   description: Number of seconds to hold the pointer down.
      #   example: 5
      #   default: 1
      #
      # button
      #  Symbol
      #   description: Button symbol supported values are: :NoButton, :Left, :Right, :Middle .
      #   example: :Right
      #   default: :Left
      #
      # tap_params
      #  Hash
      #   description: Hash with additional tap parameters. Link to table TBA
      #   example: {:behavior_name => 'long_tap', :use_tap_screen => true}
      #   default: {}
      #
      # == returns
      # NilClass
      #  description: -
      #  example: -
      #
      # == exceptions
      #      
      def long_tap_object( x, y, time = 1, button = :Left, tap_params = {} )

        begin

          tap_down_object(x, y, button, tap_params)
          sleep time
          tap_up_object(x, y, button, tap_params)

        rescue Exception

          $logger.behaviour "FAIL;Failed long_tap_object with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_tap_object;"

          raise

        end

        $logger.behaviour "PASS;Operation long_tap_object executed successfully with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_tap_object;"

        nil

      end


      # == description
      # Tap down the screen on the coordinates of the object. TBA link to generic information about tapping, options read from TDriver parameters etc.
      #
      # == arguments
      # button
      #  Symbol
      #   description: button to tap down
      #   example: :Right
      # refresh
      #  Boolean
      #   description: if true, object will be refreshed after tap_down
      #   example: true
      # tap_params
      #  Hash
      #   description: arguments, link to table TBA
      #   example: -
      #
      # == returns
      # NilClass
      #   description: -
      #   example: nil
      #
      # == exceptions
      # TestObjectNotFoundError
      #  description: object is not visible on screen
      # ArgumentError
      #   description: invalid button
      def tap_down( button = :Left, refresh = false, tap_params = {} )

        begin
          use_tap_screen = tap_params[:use_tap_screen].nil? ? sut_parameters[ :use_tap_screen, 'false'] : tap_params[:use_tap_screen].to_s
          tap_params[:useTapScreen] = use_tap_screen

          raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(button)
          command = command_params #in qt_behaviour
          command.command_name('MousePress')

          params = {
            'button' => @@_buttons_map[button],
            'mouseMove' => sut_parameters[ :in_tap_move_pointer, 'false' ],
            'useTapScreen' => use_tap_screen,
            'x_off' => sut_parameters[:tap_x_offset , '0' ],
            'y_off' => sut_parameters[:tap_y_offset , '0' ]
          }

          if attribute('objectType') == 'Web' or attribute('objectType') == 'Embedded'
            params['x'] = center_x
            params['y'] = center_y
            params['useCoordinates'] = 'true'
          end
          params.merge!(tap_params)

          command.command_params(params)
          execute_behavior(tap_params, command)

          force_refresh( :id => get_application_id ) if refresh

        rescue Exception

          $logger.behaviour "FAIL;Failed tap_down with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};tap_down;"

          raise

        end

        $logger.behaviour "PASS;Operation tap_down executed successfully with with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};tap_down;"

        nil

      end



      # == description
      # Release tap on the coordinates of the object. TBA link to generic information about tapping, options read from TDriver parameters etc.
      #
      # == arguments
      # button
      #  Symbol
      #   description: button to tap down
      #   example: :Right
      # refresh
      #  Boolean
      #   description: if true, object will be refreshed after tap_down
      #   example: false
      # tap_params
      #  Hash
      #   description: arguments, link to table TBA
      #   example: -
      #
      # == returns
      # NilClass
      #   description: -
      #   example: nil
      #
      # == exceptions
      # TestObjectNotFoundError
      #  description: object is not visible on screen
      # ArgumentError
      #   description: invalid button
      def tap_up( button = :Left, refresh = true, tap_params = {} )

        begin
          use_tap_screen = tap_params[:use_tap_screen].nil? ? sut_parameters[ :use_tap_screen, 'false'] : tap_params[:use_tap_screen].to_s
          tap_params[:useTapScreen] = use_tap_screen

          raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(button)
          command = command_params #in qt_behaviour
          command.command_name('MouseRelease')
          params = {'button' => @@_buttons_map[button], 'useTapScreen' => use_tap_screen}

          if attribute('objectType') == 'Web' or attribute('objectType') == 'Embedded'
            params['x'] = center_x
            params['y'] = center_y
            params['useCoordinates'] = 'true'
            params['x_off'] = sut_parameters[:tap_x_offset , '0' ]
            params['y_off'] = sut_parameters[:tap_y_offset , '0' ]

          end
          params.merge!(tap_params)

          command.command_params(params)

          execute_behavior(tap_params, command)
          force_refresh({:id => get_application_id}) if refresh

        rescue Exception

          $logger.behaviour "FAIL;Failed tap_up with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};tap_up;"

          raise

        end

        $logger.behaviour "PASS;Operation tap_up executed successfully with with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};tap_up;"

        nil

      end

      # TODO: [2009-04-02] Remove deprevated methods?

      # warning: TestObject#press is deprecated; use TestObject#tap
      # == deprecated
      # 0.8.x
      # == description
      # TestObject#press is deprecated, use TestObject#tap instead.
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
                                 'mouseMove'=>'true',
                                 'x_off' => sut_parameters[:tap_x_offset , '0' ],
                                 'y_off' => sut_parameters[:tap_y_offset , '0' ]
                                 )

          @sut.execute_command(command)

        rescue Exception

          $logger.behaviour "FAIL;Failed press with tap_count \"#{tap_count}\", button \"#{button.to_s}\".;#{identity};press;"

          raise

        end

        $logger.behaviour "PASS;Operation press executed successfully with tap_count \"#{tap_count}\", button \"#{button.to_s}\".;#{identity};press;"

        nil

      end

      # TestObject#long_press is deprecated; use TestObject#long_tap
      # == deprecated
      # 0.8.x
      # == description
      # TestObject#long_press is deprecated, use TestObject#long_tap instead.
      def long_press( time = 1, button = :Left )

        $stderr.puts "#{ caller(0).last.to_s } warning: TestObject#long_press is deprecated; use TestObject#long_tap"

        begin

          long_tap(time, button)

        rescue Exception

          $logger.behaviour "FAIL;Failed long_press with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_press;"

          raise

        end

        $logger.behaviour "PASS;Operation long_press executed successfully with time \"#{time.to_s}\", button \"#{button.to_s}\".;#{identity};long_press;"

        nil

      end

      # TestObject#hold is deprecated; use TestObject#tap_down
      # == deprecated
      # 0.8.x
      # == description
      # TestObject#hold is deprecated, use TestObject#tap_down instead.
      def hold(button = :Left, refresh = true)

        $stderr.puts "#{ caller(0).last.to_s } warning: TestObject#hold is deprecated; use TestObject#tap_down"

        begin

          tap_down(button, refresh)

        rescue Exception

          $logger.behaviour "FAIL;Failed hold with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};hold;"

          raise

        end

        $logger.behaviour "PASS;Operation hold executed successfully with with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};hold;"

        nil

      end

      # TestObject#release is deprecated; use TestObject#tap_up
      # == deprecated
      # 0.8.x
      # == description
      # TestObject#release is deprecated, use TestObject#tap_up instead.
      def release( button = :Left, refresh = true )

        $stderr.puts "#{ caller(0).last.to_s } warning: TestObject#release is deprecated; use TestObject#tap_up"

        begin

          tap_up(button, refresh)

        rescue Exception

          $logger.behaviour "FAIL;Failed release with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};release;"

          raise

        end

        $logger.behaviour "PASS;Operation release executed successfully with with button \"#{button.to_s}\", refresh \"#{refresh.to_s}\".;#{identity};release;"

        nil

      end

=begin
         private

         def center_x
           x = attribute('x_absolute').to_i
           width = attribute('width').to_i
           x = x + (width/2)
           x.to_s
         end

         def center_y
           y = attribute('y_absolute').to_i
           height = attribute('height').to_i
           y = y + (height/2)
           y.to_s
         end
=end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

     end # Widget


   end # QT

 end # MobyBehaviour
