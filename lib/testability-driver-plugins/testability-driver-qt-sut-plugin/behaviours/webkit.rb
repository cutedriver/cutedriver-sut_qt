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

    # == description
    # Webkit specific behaviours
    #
    # == behaviour
    # QtWebkit
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # *
    #
    # == sut_type
    # QT;S60QT
    #
    # == sut_version
    # *
    #
    # == objects
    # *
    #
    module Webkit

      include MobyBehaviour::QT::Behaviour

      # == nodoc
      # == description
      # Send javascript to target object on the screen
      # == params
      # java_script::( )java script to be executed to target object
      # == returns  
      # == raises
      # TestObjectNotFoundError:: If a graphics item is not visible on screen
      # ArgumentError:: If an invalid button type is given
      # ArgumentError:: If coordinates are outside of the object
      # === examples
      #  @object.execute_javascript_query
      def execute_javascript_query(java_script, locator_query = nil, index = -1, webframe_id = 0)   

        returnValue = ""
        
        begin   
          
          command = command_params #in qt_behaviour           
=begin
             if(locator_query == nil)
               command.command_name('ExecuteJavaScriptOnQWebFrame')
               locator_query=""
             else  
               command.command_name('ExecuteJavaScriptOnWebElement')
             end
=end                  

          if type != "QWebFrame"
            command.command_name('ExecuteJavaScriptOnWebElement')
            webframe_id = attribute('webFrame') if webframe_id.to_s == "0"				  
          else
            command.command_name('ExecuteJavaScriptOnQWebFrame')
          end

          command.service( 'webkitCommand' )
          params = {
            'java_script'   => java_script,
            'locator_query' => locator_query,
            'index'         => index.to_s,
            'elementId'     => @id.to_s, 
            'webframe_id'   => webframe_id.to_s
          }
          
          command.command_params( params )
          
          returnValue = @sut.execute_command( command )
          
        rescue Exception => e      

          $logger.behaviour "FAIL;Failed send javascript with execute_javascript \"#{java_script}\""
          raise e        

        end      

        $logger.behaviour "PASS;Operation send javascript executed successfully with execute_javascript \"#{java_script}\""

        returnValue

      end
      
      # == description
      # Executes java script on the target test object			
      #
      # == arguments
      # java_script
      #  String
      #   description: Script to be executed to target object
      #   example: "this.onclick();"
      #
      # == returns
      # MobyBase::TestObject
      #  description: Target test object 
      #  example: -
      #
      # == raises
      # RuntimeError
      #  description: When executing JavaScript to QWebFrame: QWebPage not found.
      #
      # RuntimeError
      #  description: When executing JavaScript to QWebFrame: QWebFrame not found.
      #
      # RuntimeError
      #  description: When executing JavaScript to WebElement: QWebPage not found.
      #
      # RuntimeError
      #  description: When executing JavaScript to WebElement: QWebElement not found.
      #
      def execute_javascript( java_script )   
        
        webframe_id = 0
        query = ""
        index = -1
        if type == "QWebFrame"
          query = nil
        else
          query << self.type.to_s 
          creation_attributes.each {|param, value|
            if param.to_s == "__index"
              index=value.to_i
              next
            end 
            query << "[" << param.to_s << "='" << value.to_s << "'" << "]"
          }
        end
        
        if type != "QWebFrame" #&& parent_object.type == "QWebFrame")
          #webframe_id = parent_object.id
          webframe_id = attribute('webFrame')
        end

        execute_javascript_query( java_script, nil, index, webframe_id)
      end

      # == description
      # Scroll QWebFrame to correct position. Valid target object types are: QWebFrame, all QWebElements.
      #
      # == arguments
      # dx
      #  Fixnum
      #   description: Delta x in pixels, positive value to right negative to left. Ignored for QWebElements. 
      #   example: 313
      #
      # dy
      #  Fixnum
      #   description: Delta y in pixels, positive value to down negative to up. Ignored for QWebElements.
      #   example: 313
      #
      # center 
      #  Fixnum
      #   description: Value 1 means that scroll is done only to reveal the center position of the element. Value 0 means that element is tried to bring fully visible. Ignored for QWebFrame.
      #   example: 1
      #
      # == returns
      # NilClass
      #  description: -
      #  example: -
      #
      # == exceptions
      # RuntimeError
      #  description: Scrollign webframe failed with error: %s
      #
      # === examples
      #  @QwebFrame.scroll(0, 10)
      #  @app.a.scroll()
      def scroll( dx = 0, dy = 0, center = 0 )   
        temp_id = ""

        if type == "QWebFrame"
          temp_id = @id
        else
          temp_id = attribute('webFrame')
		  
		  elemens_xml_data, unused_rule = @test_object_adapter.get_objects( @sut.xml_data, { :id => attribute('webFrame')}, true )
		  object_xml_data = elemens_xml_data[0]
		  object_attributes = @test_object_adapter.test_object_attributes(object_xml_data)
		  x_absolute = object_attributes['x_absolute'].to_i 
		  y_absolute = object_attributes['y_absolute'].to_i 
		  width = object_attributes['width'].to_i
		  height = object_attributes['height'].to_i 
		  horizontalScrollBarHeight =  object_attributes['horizontalScrollBarHeight'].to_i
		  verticalScrollBarWidth = object_attributes['verticalScrollBarWidth'].to_i

          #calculate borders
          frame_down_border = y_absolute + height - horizontalScrollBarHeight
          frame_right_border = x_absolute + width - verticalScrollBarWidth

          if(center==1)
            
            #adjust image to be visible for tap
            if(center_y.to_i > frame_down_border)
              dy = center_y.to_i - frame_down_border + 5
            elsif (center_y.to_i < y_absolute) 
              dy = center_y.to_i - y_absolute - 5
            end
            
            if(center_x.to_i > frame_right_border)
              dx = center_x.to_i - frame_right_border + 1
            elsif (center_x.to_i < x_absolute)
              dx = center_x.to_i - x_absolute - 1
            end
          else
            #bring fully visible
            if(center_y.to_i > frame_down_border)
              dy = attribute("y_absolute").to_i + attribute("height").to_i - y_absolute - height + horizontalScrollBarHeight
            elsif (center_y.to_i < y_absolute)
              dy = attribute("y_absolute").to_i - y_absolute
            end
            
            if(center_x.to_i > frame_right_border)
              dx = attribute("x_absolute").to_i + attribute("width").to_i - x_absolute - width + verticalScrollBarWidth
            elsif (center_x.to_i < x_absolute)
              dx = attribute("x_absolute").to_i - x_absolute
            end
          end
        end

        command = command_params #in qt_behaviour                   
        command.command_name('ScrollQWebFrame')

        command.service( 'webkitCommand' )
        params = {
          'dx' => dx.to_s,
          'dy'=> dy.to_s,
          'target_webframe'=> temp_id
        }

        command.command_params( params )

        returnValue = @sut.execute_command( command )
        raise RuntimeError.new( "Scrollign webframe failed with error: %s" % [ returnValue ] ) if ( returnValue != "OK" )

      end


      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )


    end # Webkit

  end # QT

end # MobyBehaviour
