############################################################################
## 
## Copyright (C) 2017 Link Motion Oy
## Author(s): Juhapekka Piiroinen <juhapekka.piiroinen@link-motion.com>
##
## All rights reserved. 
## Contact: Link Motion (info@link-motion.com) 
## 
## This file is part of CuteDriver. 
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
        #
        # == behaviour
        # QtPwr
        #
        # == requires
        # testability-driver-qt-sut-plugin
        #
        # == input_type
        # *
        #
        # == sut_type
        # QT
        #
        # == sut_version
        # *
        #
        # == objects
        # *
        #
        module Pwr
    
          include MobyBehaviour::QT::Behaviour
    
          # == description
          # Start collecting PWR usage per second data for the app. 
          # 
          # == returns
          # NilClass
          #   description: -
          #   example: -
          #
          # == exceptions
          # ArgumentError
          #  description:  In case the given parameters are not valid.
          #    
          def start_pwr_measurement
    
            begin
    
              log_pwr(:interval => 1, :filePath => '/tmp') 
    
            rescue Exception
    
              $logger.behaviour "FAIL;Failed start_pwr_measurement.;#{ identity };start_pwr_measurement;"
              raise
    
            end
    
            $logger.behaviour "PASS;Operation start_pwr_measurement executed successfully.;#{ identity };start_pwr_measurement;"
    
            nil
            
          end
    
          # == description
          # Stop collecting PWR usage data for the object. 
          # 
          # == returns
          # Array
          #  description: An Array of PWR entries. Each entry is a hash table that contains the value and time stamp {value => 42.00, voltage => 32.00, current => 42.00, time_stamp => 06:49:42.259}
          #  example: [{value => 42.0, current => 42.0, voltage => 12.0, time_stamp => 06:49:42.259}, {value => 32.0, current => 32.0, voltage => 42.0, time_stamp => 06:49:43.259}]
          #
          # == exceptions
          # ArgumentError
          #  description:  In case the given parameters are not valid.
          #    
          def stop_pwr_measurement
    
            begin
    
              results = parse_results_pwr( stop_pwr_log() )
    
            rescue Exception
    
              $logger.behaviour "FAIL;Failed stop_pwr_measurement.;#{ identity };stop_pwr_measurement;"
    
              raise
    
            end
    
            $logger.behaviour "PASS;Operation stop_pwr_measurement executed successfully.;#{ identity };stop_pwr_measurement;"
    
            results
    
          end
    
    
        private
          
          def parse_results_pwr( results_xml )
            state_object = @sut.state_object( results_xml )
            
            results = []
    
            count = state_object.logData.attribute( 'entryCount' ).to_i
    
            for i in 0...count
            
              value = state_object.logEntry(:id => i.to_s).attribute('current').to_f
              current = state_object.logEntry(:id => i.to_s).attribute('current').to_f
              voltage = state_object.logEntry(:id => i.to_s).attribute('voltage').to_f
              
              time_stamp = state_object.logEntry(:id => i.to_s).attribute('timeStamp')
    
              entry = {:value => value, :current => current, :voltage => voltage, :time_stamp => time_stamp}
    
              results.push(entry)
    
            end
    
            results
    
          end
          
          # enable hooking for performance measurement & debug logging
          TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
    
        end # Pwr
    
      end # QT
    
    end # MobyBase
    