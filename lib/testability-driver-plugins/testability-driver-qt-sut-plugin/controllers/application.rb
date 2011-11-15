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

module MobyController
  
  module QT
  
    module Application 
      
      include MobyController::Abstraction

      include MobyUtil::MessageComposer
      
      # create message to be sent sut SUT adapter - returns [ "message_body", boolean ]
      def make_message

        return_response_crc = false

        case @_command
        
          # application ui state
          when  :State        

            command_xml = state_message

            return_response_crc = true
          
          # launch application
          when :Run
          
            command_xml = run_message

          # close
          when :Close
          
            command_xml = close_message

          # close qttas
          when :CloseQttas

            command_xml = make_xml_message( { :service => 'closeApplication' }, 'Close', { 'uid' => '0' } )

          # kill application
          when :Kill

            command_xml = make_xml_message( { :service => 'closeApplication' }, 'Kill', { 'uid' => @_application_uid } )

          # list applications          
          when :ListApps

            service_details = { 
              :service => 'listApps', 
              :name => @_application_name, 
              :id => @_application_uid 
            }

            command_xml = make_xml_message( service_details, 'listApps', nil )

          # list applications          
          when :ListRunningProcesses

            service_details = { 
              :service => 'listRunningProcesses', 
              :name => @_application_name, 
              :id => @_application_uid 
            }

            command_xml = make_xml_message( service_details, 'listRunningProcesses', nil )

          # list started applications          
          when :ListStartedApps

            service_details = { 
              :service => 'startedApps', 
              :name => @_application_name, 
              :id => @_application_uid 
            }

            command_xml = make_xml_message( service_details, 'startedApps', nil )

          # shell command
          when :Shell

            command_xml = make_xml_message( { :service => 'shellCommand' }, 'shellCommand', @_flags, @_application_name )

          # kill all application started by agent_qt
          when :KillAll

            command_xml = make_xml_message( { :service => 'kill' }, 'Kill', nil )

          # tap screen
          when :TapScreen

            command_xml = make_xml_message( { :service =>'tapScreen' }, 'TapScreen', params)

          # bring application to foreground
          when :BringToForeground

            command_xml = make_xml_message( { :service => 'bringToForeground' }, 'BringToForeground', { 'pid' => @_application_uid } )
          
          # system info
          when :SystemInfo

            command_xml = make_xml_message( { :service => 'systemInfo' }, 'systemInfo', nil)
          
          # start process memory logging
          when :ProcessMemLoggingStart
          
            parameters = {
              'thread_name' => @_application_name, 
              'file_name' => @_flags[ :file_name ],
              'timestamp' => @_flags[ :timestamp ],
              'interval_s' => @_flags[ :interval_s ]
            }

            command_xml = make_xml_message( { :service => 'resourceLogging' }, 'ProcessMemLoggingStart', parameters )

          # stop process memory logging
          when :ProcessMemLoggingStop

            parameters = {
              'thread_name' => @_application_name,
              'return_data' => @_flags[ :return_data ]
            }

            command_xml = make_xml_message( { :service =>'resourceLogging' }, 'ProcessMemLoggingStop', parameters )

          # start CPU load generating
          when :CpuLoadStart

            parameters = {
              'cpu_load' => @_flags[ :cpu_load ]
            }

            command_xml = make_xml_message( { :service => 'resourceLogging' }, 'CpuLoadStart', parameters )

          # stop CPU load generating
          when :CpuLoadStop
          
            command_xml = make_xml_message( { :service => 'resourceLogging' }, 'CpuLoadStop', nil )

          # list application -- raises exception??
          #when :List

            #raise ArgumentError, "Unknown command! #{ @_command.to_s }"
            
        else
        
          # unknown command
          raise ArgumentError, "Unknown command! #{ @_command.to_s }"
          
        end

        [ Comms::MessageGenerator.generate( command_xml ), return_response_crc ]

      end

      # Execute the command 
      # Sends the message to the device using the @sut_adapter (see base class)     
      # == params         
      # == returns
      # == raises
      # ArgumentError: raised if unsupported command type   
      def execute
    
        message, return_response_crc = make_message

        @sut_adapter.send_service_request( message, return_response_crc ) if message    

      end

    end # Application

  end  # QT    

end # MobyController
