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
        # QtGpu
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
        module Gpu
    
          include MobyBehaviour::QT::Behaviour
    
          # == description
          # Start collecting GPU usage per second data for the app. 
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
          def start_gpu_measurement
    
            begin
    
              log_gpu_mem(:interval => 1, :filePath => '/tmp') 
    
            rescue Exception
    
              $logger.behaviour "FAIL;Failed start_gpu_mem_measurement.;#{ identity };start_gpu_mem_measurement;"
              raise
    
            end
    
            $logger.behaviour "PASS;Operation start_gpu_mem_measurement executed successfully.;#{ identity };start_gpu_mem_measurement;"
    
            nil
            
          end
    
          # == description
          # Stop collecting GPU usage data for the object. 
          # 
          # == returns
          # Array
          #  description: An Array of GPU entries. Each entry is a hash table that contains the value and time stamp {value => 42.00, usedMem => 42.00, freeMem => 12.34, totalMem => 43.21, processPrivateMem => 32.14, processSharedMem => 23.41 time_stamp => 06:49:42.259}
          #  example: [{value => 42.0, usedMem => 42.0, freeMem => 123.0, totalMem => 256.0, processPrivateMem => 12.0, processSharedMem => 32.0, time_stamp => 06:49:42.259}, {value => 32.0, usedMem => 42.0, freeMem => 123.0, totalMem => 256.0, processPrivateMem => 12.0, processSharedMem => 32.0, time_stamp => 06:49:43.259}]
          #
          # == exceptions
          # ArgumentError
          #  description:  In case the given parameters are not valid.
          #    
          def stop_gpu_measurement
    
            begin
    
              results = parse_results_gpu( stop_gpu_log() )
    
            rescue Exception
    
              $logger.behaviour "FAIL;Failed stop_gpu_measurement.;#{ identity };stop_gpu_measurement;"
    
              raise
    
            end
    
            $logger.behaviour "PASS;Operation stop_gpu_measurement executed successfully.;#{ identity };stop_gpu_measurement;"
    
            results
    
          end
    
    
        private
          
          def parse_results_gpu( results_xml )
            state_object = @sut.state_object( results_xml )
    
            results = []
    
            count = state_object.logData.attribute( 'entryCount' ).to_i
    
            for i in 0...count
              totalMem = state_object.logEntry(:id => i.to_s).attribute('totalMem').to_f
              usedMem = state_object.logEntry(:id => i.to_s).attribute('usedMem').to_f
              freeMem = state_object.logEntry(:id => i.to_s).attribute('freeMem').to_f
              processPrivateMem = state_object.logEntry(:id => i.to_s).attribute('processPrivateMem').to_f              
              processSharedMem = state_object.logEntry(:id => i.to_s).attribute('processSharedMem').to_f
    
              time_stamp = state_object.logEntry(:id => i.to_s).attribute('timeStamp')
    
              entry = {:value => usedMem, :usedMem => usedMem, :freeMem => freeMem, :totalMem => totalMem, :processPrivateMem => processPrivateMem, :processSharedMem => processSharedMem, :time_stamp => time_stamp}
    
              results.push(entry)
    
            end
    
            results
    
          end
          
          # enable hooking for performance measurement & debug logging
          TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
    
        end # Gpu
    
      end # QT
    
    end # MobyBase
    