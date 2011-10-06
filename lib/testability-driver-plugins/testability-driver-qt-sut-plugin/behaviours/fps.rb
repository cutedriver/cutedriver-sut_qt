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
    #
    # == behaviour
    # QtFps
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
    module Fps

      include MobyBehaviour::QT::Behaviour

      # == description
      # Start collecting frames per second data for the object. 
      # Testability driver qttas package provides a fixture for measuring fps of a component. 
      # This behaviour is a wrapper for the fixture.
      # The fixture intercepts paint events send to the target of the fps measurement and simply 
      # counts how many occur during each second. The way this is done differs a bit depending 
      # on the target object. For normal QWidgets the fps values are measured to the target 
      # object direclty. QGraphicsItem based objects this is not the case. For QGrapchisItem 
      # based objects the system determines the QGraphicsView the item is in and starts to 
      # listen to paint evets send to the viewport of the QGraphicsView. If you measure the 
      # QGraphicsView object directly the measurement is also done for the viewport.
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
      def start_fps_measurement

        begin

          fixture('fps', 'startFps')

        rescue Exception

          $logger.behaviour "FAIL;Failed start_fps_measurement.;#{ identity };start_fps_measurement;"
          raise

        end

        $logger.behaviour "PASS;Operation start_fps_measurement executed successfully.;#{ identity };start_fps_measurement;"

        nil
        
      end

      # == description
      # Stop collecting frames per second data for the object. 
      # 
      # == returns
      # Array
      #  description: An Array of fps entries. Each entry is a hash table that contains the value and time stamp {value => 12, time_stamp => 06:49:42.259}
      #  example: [{value => 12, time_stamp => 06:49:42.259}, {value => 11, time_stamp => 06:49:43.259}]
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
      #    
      def stop_fps_measurement

        begin

          results = parse_results( fixture('fps', 'stopFps') )

        rescue Exception

          $logger.behaviour "FAIL;Failed stop_fps_measurement.;#{ identity };stop_fps_measurement;"

          raise

        end

        $logger.behaviour "PASS;Operation stop_fps_measurement executed successfully.;#{ identity };stop_fps_measurement;"

        results

      end

      # == description
      # Collect the stored fps results from the target. This will not stop the measurement but it will restart it
      # so the results returned will not be included in the next data request. Measuring fps will have a small impact
      # on the software performance and memory consumption so it is recommended that the collection is stopped if no longer
      # needed.
      # 
      # == returns
      # Array
      #   description: An Array of fps entries. Each entry is a hash table that contains the 
      #                value and time stamp {value => 12, time_stamp => 06:49:42.259}
      #   example: [{value => 12, time_stamp => 06:49:42.259}, {value => 11, time_stamp => 06:49:43.259}]
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
      #    
      def collect_fps_data

        begin

          results = parse_results( fixture('fps', 'collectData') )

        rescue Exception

          $logger.behaviour "FAIL;Failed collect_fps_data.;#{ identity };collect_fps_data;"

          raise

        end

        $logger.behaviour "PASS;Operation collect_fps_data executed successfully.;#{ identity };collect_fps_data;"

        results

      end

    private
      
      def parse_results( results_xml )

        state_object = @sut.state_object( results_xml )

        results = []

        count = state_object.results.attribute('count').to_i

        for i in 0...count
        
          value = state_object.fps(:id => i.to_s).attribute('frameCount').to_i

          time_stamp = state_object.fps(:id => i.to_s).attribute('timeStamp')

          entry = {:value => value, :time_stamp => time_stamp}

          results.push(entry)

        end

        results

      end
      
      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # Fps

  end # QT

end # MobyBase
