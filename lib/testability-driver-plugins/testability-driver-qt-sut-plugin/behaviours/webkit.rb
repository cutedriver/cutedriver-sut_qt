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
                  Kernel::raise RuntimeError.new( "Running Javascript '%s' failed with error: %s" % [ java_script, returnValue ] ) if ( returnValue != "OK" )
          
                rescue Exception => e      

                    MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed send javascript with execute_javascript \"#{java_script}\""
                    Kernel::raise e        

                end      

                MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation send javascript executed successfully with execute_javascript \"#{java_script}\""

                nil

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

				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


		end # Webkit

	end # QT

end # MobyBehaviour
