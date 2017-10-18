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
        # QtMem
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
        module Mem
    
          include MobyBehaviour::QT::Behaviour
    
          # == description
          # Start collecting MEM usage per second data for the app. 
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
          def start_mem_measurement
    
            begin
    
              log_mem(:interval => 1, :filePath => '/tmp') 
    
            rescue Exception
    
              $logger.behaviour "FAIL;Failed start_mem_measurement.;#{ identity };start_mem_measurement;"
              raise
    
            end
    
            $logger.behaviour "PASS;Operation start_mem_measurement executed successfully.;#{ identity };start_mem_measurement;"
    
            nil
            
          end
    
          # == description
          # Stop collecting MEM usage data for the object. 
          # 
          # == returns
          # Array
          #  description: An Array of MEM entries. Each entry is a hash table that contains the value and time stamp {value => 42.00, heapSize => 42.00, time_stamp => 06:49:42.259}
          #  example: [{value => 42.0, heapSize => 42.0, time_stamp => 06:49:42.259}, {value => 32.0, heapSize => 32.0, time_stamp => 06:49:43.259}]
          #
          # == exceptions
          # ArgumentError
          #  description:  In case the given parameters are not valid.
          #    
          def stop_mem_measurement
    
            begin
    
              results = parse_results_mem( stop_mem_log() )
    
            rescue Exception
    
              $logger.behaviour "FAIL;Failed stop_mem_measurement.;#{ identity };stop_mem_measurement;"
    
              raise
    
            end
    
            $logger.behaviour "PASS;Operation stop_mem_measurement executed successfully.;#{ identity };stop_mem_measurement;"
    
            results
    
          end
    
    
        private
          
          def parse_results_mem( results_xml )
            state_object = @sut.state_object( results_xml )
            results = []
    
            count = state_object.logData.attribute( 'entryCount' ).to_i
    
            for i in 0...count
              heapSize = state_object.logEntry(:id => i.to_s).attribute('heapSize').to_i
    
              time_stamp = state_object.logEntry(:id => i.to_s).attribute('timeStamp')
    
              entry = {:value => heapSize, :heapSize => heapSize, :time_stamp => time_stamp}
    
              results.push(entry)
    
            end
    
            results
    
          end
          
          # enable hooking for performance measurement & debug logging
          TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
    
        end # Mem
    
      end # QT
    
    end # MobyBase
    