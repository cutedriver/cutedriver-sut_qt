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
                  webframe_id = self.attribute('webFrame') if webframe_id.to_s == "0"				  
                  else
                  command.command_name('ExecuteJavaScriptOnQWebFrame')
                  end

                  command.service( 'webkitCommand' )
                  params = {
                    'java_script'   => java_script,
                    'locator_query' => locator_query,
                    'index'         => index.to_s,
                    'elementId'     => self.id.to_s, 
                    'webframe_id'   => webframe_id.to_s
                  }
                  
                  command.command_params( params )
                  
                  returnValue = @sut.execute_command( command )
          
                rescue Exception => e      

                    MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed send javascript with execute_javascript \"#{java_script}\""
                    Kernel::raise e        

                end      

                MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation send javascript executed successfully with execute_javascript \"#{java_script}\""

              returnValue

            end


			
			# Send javascript to target object on the screen
			# == params
			# java_script::( )java script to be executed to target object
			# == returns  
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If an invalid button type is given
			# ArgumentError:: If coordinates are outside of the object
			# === examples
			#  @object.execute_javascript
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
				webframe_id = self.attribute('webFrame')
    		  end

              execute_javascript_query( java_script, nil, index, webframe_id)
			end

			# Scrolls the 
			# == params
			# dx, dy. pixels to scroll down (value may be negative)
			# == returns  
			# == raises
			# === examples
			#  @QwebFrame.scroll(0, 10)
			#  @app.a.scroll()
      def scroll( dx=0, dy=0, tap=0 )   
                
        frame = self
        if type != "QWebFrame"
          until frame.type.to_s == "QWebFrame"
            frame = frame.get_parent
          end
          
          #calculate borders
          frame_down_border = frame.attribute("y_absolute").to_i + frame.attribute("height").to_i - frame.attribute("horizontalScrollBarHeight").to_i
          frame_right_border = frame.attribute("x_absolute").to_i + frame.attribute("width").to_i - frame.attribute("verticalScrollBarWidth").to_i

          if(tap==1)
            
            #adjust image to be visible for tap
            if(center_y.to_i > frame_down_border)
              dy = center_y.to_i - frame_down_border + 1
            elsif (center_y.to_i < frame.attribute("y_absolute").to_i) 
              dy = center_y.to_i - frame.attribute("y_absolute").to_i - 1
            end
            
            if(center_x.to_i > frame_right_border)
              dx = center_x.to_i - frame_right_border + 1
            elsif (center_x.to_i < frame.attribute("x_absolute").to_i)
              dx = center_x.to_i - frame.attribute("x_absolute").to_i - 1
            end
          else
            #bring fully visible
            if(center_y.to_i > frame_down_border)
              dy = self.attribute("y_absolute").to_i + self.attribute("height").to_i - frame.attribute("y_absolute").to_i - frame.attribute("height").to_i + frame.attribute("horizontalScrollBarHeight").to_i
            elsif (center_y.to_i < frame.attribute("y_absolute").to_i) 
              dy = self.attribute("y_absolute").to_i - frame.attribute("y_absolute").to_i 
            end
          
            if(center_x.to_i > frame_right_border)
              dx = self.attribute("x_absolute").to_i + self.attribute("width").to_i - frame.attribute("x_absolute").to_i - frame.attribute("width").to_i + frame.attribute("verticalScrollBarWidth").to_i
            elsif (center_x.to_i < frame.attribute("x_absolute").to_i)
              dx = self.attribute("x_absolute").to_i - frame.attribute("x_absolute").to_i
            end
          end
          
          puts "x(" + dx.to_s + ") y(" + dy.to_s + ")"
          
          frame.scroll(dx,dy)
          return
        end

        command = command_params #in qt_behaviour                   
        command.command_name('ScrollQWebFrame')

        command.service( 'webkitCommand' )
        params = {
          'dx' => dx.to_s,
          'dy'=> dy.to_s
        }

        command.command_params( params )

        returnValue = @sut.execute_command( command )
        Kernel::raise RuntimeError.new( "Running Javascript '%s' failed with error: %s" % [ java_script, returnValue ] ) if ( returnValue != "OK" )

      end


				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


		end # Webkit

	end # QT

end # MobyBehaviour
