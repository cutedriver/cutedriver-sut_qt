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
    # This module contains implementation to control info logging for cpu, mem, and gpu
    #
    # == behaviour
    # InfoLogger
    #
    # == requires
    # testability-driver-qt-sut-plugin
    #
    # == input_type
    # *
    #
    # == sut_type
    # qt
    #
    # == sut_version
    # *
    #
    # == objects
    # sut;application
    #
    module InfoLoggerBehaviour

      include MobyBehaviour::QT::Behaviour

      # == description
      # Starts logging the cpu usage the application or qttasserver if called for sut. Logging is done to a file in the given intervals (seconds).
      # Small (<1) intervals may cause problems and should be avoided.
      #
      # The default behaviour is that a new log file will be started whenever the logging is started.
      # If you need to save the old results use the append parameter to tell the logger to append the results to the existing file.
      #
			# == arguments
			# params
      #  Hash
      #   description: Update interval and path for the log file. Interval value is in seconds.
      #   The file path given must exist on the target.
      #   Optional append parameter can also be given and if true the log file will not be cleared if one exists (by default a new file will always be started).
			#   example: {:interval => 1, :filePath => 'C:\Data', :append => true}
			#   default: No default values, must be set
			#
			# == returns
			# nil
      #  description: -
      #  example: -
      #
			# == exceptions
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
      def log_cpu(params)
        params[:action] = 'start'
        execute_info('cpu', params)
      end

      # == description
      # Stops the cpu load logging and returns the results and xml data.
      # Will return an error if the logging was not started.
      # The logging is done by writing the values to a log file.
      # When the logging is stopped the file is read and a xml format of the data is returned.
      # The file is removed.\n
      # 
      # The data is returned in the same format as the ui state xml. Each log enty contains a timestamp the and cpu load value.\n
      #
      # The top object is of type logData and name cpuLoad. It contains the number of entries. The entries are the child elements of logData element.
      #
      # [code]
      #   <object id="0" name="cpuLoad" type="logData" >
      #    <attributes>
      #      <attribute name="entryCount" >
      #        <value>8</value>
      #      </attribute>
      #     </attributes>
      #   <object>       
      # [/code]
      #
      # Each logEntry contains a timeStamp (yyyyMMddhhmmsszzz) and cpuLoad (%).\n
      #
      # [code]
      #  <object id="0" name="LogEntry" type="logEntry" >
      #    <attributes>
      #      <attribute name="timeStamp" >
      #        <value>20100109184651114</value>
      #       </attribute>
      #      <attribute name="cpuLoad" >
      #        <value>21.8966</value>
      #      </attribute>
      #    </attributes>
      #   </object>
      # [/code]
      #
      # You can use xpath to access the data directly to form any your own reports. Another way is to create a state object out of the data. This way you can access the data as you access ui state objects.
      #
      # [code]
      #     #start logging
      #      @app.log_cpu({:interval => 1, :filePath => 'C:\Data'})
      #
      #     #perform testing...
      #
      #     #stop logging and get data as state object
      #      cpu_data = MobyBase::StateObject.new( @app.stop_cpu_log )
      #
      #      #loop the data to make a graph using gruf
      #      count = cpu_data.logData.attribute('entryCount').to_i
      #      i = 0
      #      data = Array.new
      #      while i < count do
      #        data.push(cpu_data.logEntry(:id => i.to_s).attribute('cpuLoad').to_i)
      #        i += 1
      #      end
      #      g = Gruff::Line.new
      #      g.title = "Application cpu usage%"
      #      g.data('Cpu Usage', data)
      #      g.write("Cpu_load.png")
      #
      # [/code]
      #
      # The example produces a graph which shows the cpu load (values depend on the testing steps, device, platform etc...).
      #
			# == arguments
			# params
      #  Hash
      #   description: Optional parameters.
			#   example: {:clearLog => true}
			#   default: No default values, must be set
			#
			# == returns
			# Xml
      #  description: data is returned in the same format as the ui state xml
      #  example: <object id="0" name="LogEntry" type="logEntry" >
      #    <attributes>
      #      <attribute name="timeStamp" >
      #        <value>20100109184651114</value>
      #       </attribute>
      #      <attribute name="cpuLoad" >
      #        <value>21.8966</value>
      #      </attribute>
      #    </attributes>
      #   </object>
      #
			# == exceptions
      # RuntimeError
      #  description: When no data has been colleted
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
      def stop_cpu_log(params={})
        params[:action] = 'stop'
        execute_info('cpu', params)
      end

      # == description
      # Starts logging the memory usage of the application or sut.
      # Normally this is the heap size used. Logging is done to a file in the given intervals (seconds).
      # Small (<1) intervals may cause problems and should be avoided.
      #
      # The default behaviour is that a new log file will be started whenever the logging is started.
      # If you need to save the old results use the append parameter to tell the logger to append the results to the existing file.
      #
			# == arguments
			# params
      #  Hash
      #   description: Update interval and path for the log file. Interval value is in seconds.
      #   The file path given must exist on the target.
      #   Optional append parameter can also be given and if true the log file will not be cleared if one exists (by default a new file will always be started).
			#   example: {:interval => 1, :filePath => 'C:\Data', :append => true}
			#   default: No default values, must be set
			#
			# == returns
      # nil
      #  description: -
      #  example: -
			# == exceptions
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
      def log_mem(params)
        params[:action] = 'start'
        execute_info('mem', params)
      end

      # == description
      # Stops the memory logging and returns the results and xml data.
      # Will return an error if the logging was not started.
      # The logging is done by writing the values to a log file.
      # When the logging is stopped the file is read and a xml format of the data is returned. The file is removed.
      #
      # The top object is of type logData and name memUsage. It contains the number of entries. The entries are the child elements of logData element.\n
      #
      # [code]
      #   <object id="0" name="memUsage" type="logData" >
      #    <attributes>
      #      <attribute name="entryCount" >
      #        <value>8</value>
      #      </attribute>
      #     </attributes>
      #   <object>
      # [/code]
      #
      # Each logEntry contains a timeStamp (yyyyMMddhhmmsszzz) and heapSize.
      #
      # [code]
      #    <object id="0" name="LogEntry" type="logEntry" >
      #    <attributes>
      #      <attribute name="timeStamp" >
      #        <value>20100109184651114</value>
      #       </attribute>
      #      <attribute name="heapSize" >
      #        <value>3337448</value>
      #      </attribute>
      #    </attributes>
      #   </object>
      # [/code]
      #
      # You can use xpath to access the data directly to form any your own reports. Another way is to create a state object out of the data. This way you can access the data as you access ui state objects.
      #
      # [code]
      #     #start log
      #      @app.log_mem({:interval => 1, :filePath => 'C:\Data'})
      #
      #      #perform tests...
      #
      #      #stop logging and get data as state object
      #      mem_data = MobyBase::StateObject.new( @app.stop_mem_log )
      #      count = mem_data.logData.attribute('entryCount').to_i
      #      i = 0
      #      heapSize = Array.new
      #      while i < count do
      #        heapSize.push(mem_data.logEntry(:id => i.to_s).attribute('heapSize').to_i)
      #        i += 1
      #      end
      #      g = Gruff::Line.new
      #      g.title = "Application memory usage"
      #      g.data('Memory Usage', heapSize)
      #      g.write("info_mem_load.png")
      #
      #[/code]
      #
      #The example produces a graph which shows the memory usage (values depend on the testing steps, device, platform etc...).
      #
			# == arguments
			# params
      #  Hash
      #   description: Optional parameters.
			#   example: {:clearLog => true}
			#   default: No default values, must be set
			#
			# == returns
			# Xml
      #  description: data is returned in the same format as the ui state xml
      #  example: <object id="0" name="LogEntry" type="logEntry" >
      #    <attributes>
      #      <attribute name="timeStamp" >
      #        <value>20100109184651114</value>
      #       </attribute>
      #      <attribute name="heapSize" >
      #        <value>3337448</value>
      #      </attribute>
      #    </attributes>
      #   </object>
      #
			# == exceptions
      # RuntimeError
      #  description: When no data has been colleted
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
      def stop_mem_log(params={})
        params[:action] = 'stop'
        execute_info('mem', params)
      end

      # == description
      # Starts logging the gpu memory usage of the application.
      # NOTE: not supported on all platforms. Platforms not supporting will return -1 values.
      # Logging is done to a file in the given intervals (seconds). Small (<1) intervals may cause problems and should be avoided.
      #
      # The default behaviour is that a new log file will be started whenever the logging is started.
      # If you need to save the old results use the append parameter to tell the logger to append the results to the existing file.
      #
			# == arguments
			# params
      #  Hash
      #   description: Update interval and path for the log file. Interval value is in seconds.
      #   The file path given must exist on the target.
      #   Optional append parameter can also be given and if true the log file will not be cleared if one exists (by default a new file will always be started).
			#   example: {:interval => 1, :filePath => 'C:\Data', :append => true}
			#   default: No default values, must be set
			#
			# == returns
      # nil
      #  description: -
      #  example: -
			# == exceptions
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
      def log_gpu_mem(params)
        params[:action] = 'start'
        execute_info('gpu', params)
      end


      # == description
      # Stops the gpu memory logging and returns the results and xml data.
      # Will return an error if the logging was not started.
      # The logging is done by writing the values to a log file.
      # When the logging is stopped the file is read and a xml format of the data is returned. The file is removed.\n
      #
      # Top object is of type logData and name gpuMemUsage. It contains the number of entries. The entries are the child elements of logData element.
      #
      # [code]
      #   <object id="0" name="gpuMemUsage" type="logData" >
      #    <attributes>
      #      <attribute name="entryCount" >
      #        <value>8</value>
      #      </attribute>
      #    </attributes>
      #    <objects>
      # [/code]
      #
      # Each logEntry contains a timeStamp (yyyyMMddhhmmsszzz), totalMem, usedMem, freeMem, processPrivateMem and processSharedMem. Process specific details may not always be available. \n
      #
      # [code]
      #    <object id="0" name="LogEntry" type="logEntry" >
      #      <attributes>
      #        <attribute name="timeStamp" >
      #        <value>20100108190741059</value>
      #        </attribute>
      #        <attribute name="totalMem" >
      #          <value>33554432</value>
      #        </attribute>
      #        <attribute name="usedMem" >
      #          <value>17252576</value>
      #        </attribute>
      #        <attribute name="freeMem" >
      #          <value>16301856</value>
      #        </attribute>
      #        <attribute name="processPrivateMem" >
      #          <value>5170739</value>
      #        </attribute>
      #        <attribute name="processSharedMem" >
      #          <value>0</value>
      #        </attribute>
      #      </attributes>
      #    </object>
      # [/code]
      #
      # You can use xpath to access the data directly to form any your own reports. Another way is to create a state object out of the data. This way you can access the data as you access ui state objects.
      #
      # [code]
      #     #start log
      #      @app.log_gpu_mem({:interval => 1, :filePath => 'C:\Data'})
      #      #perform testing...
      #
      #      #stop logging and get data as state object
      #      gpu_data = MobyBase::StateObject.new( @app.stop_gpu_log )
      #
      #
      #      count = gpu_data.logData.attribute('entryCount').to_i
      #      i = 0
      #      totalMem = Array.new
      #      usedMem = Array.new
      #      freeMem = Array.new
      #      processPrivateMem = Array.new
      #      processSharedMem = Array.new
      #      while i < count do
      #        totalMem.push(gpu_data.logEntry(:id => i.to_s).attribute('totalMem').to_i)
      #        usedMem.push(gpu_data.logEntry(:id => i.to_s).attribute('usedMem').to_i)
      #        freeMem.push(gpu_data.logEntry(:id => i.to_s).attribute('freeMem').to_i)
      #        processPrivateMem.push(gpu_data.logEntry(:id => i.to_s).attribute('processPrivateMem').to_i)
      #        processSharedMem.push(gpu_data.logEntry(:id => i.to_s).attribute('processSharedMem').to_i)
      #        i += 1
      #      end
      #      g = Gruff::Line.new
      #      g.title = "Application cpu usage%"
      #      g.data('Total memory', totalMem)
      #      g.data('Used memory', usedMem)
      #      g.data('Free memory', freeMem)
      #      g.data('Process private memory', processPrivateMem)
      #      g.data('Process shared memory', processSharedMem)
      #      g.write("info_gpu_load.png")
      #
      # [/code]
      #
      # The example produces a graph which shows the cpu load (values depend on the testing steps, device, platform etc...).
      #
			# == arguments
			# params
      #  Hash
      #   description: Optional parameters.
			#   example: {:clearLog => true}
			#   default: No default values, must be set
			#
			# == returns
			# Xml
      #  description: data is returned in the same format as the ui state xml
      #  example: <object id="0" name="LogEntry" type="logEntry" >
      #      <attributes>
      #        <attribute name="timeStamp" >
      #        <value>20100108190741059</value>
      #        </attribute>
      #        <attribute name="totalMem" >
      #          <value>33554432</value>
      #        </attribute>
      #        <attribute name="usedMem" >
      #          <value>17252576</value>
      #        </attribute>
      #        <attribute name="freeMem" >
      #          <value>16301856</value>
      #        </attribute>
      #        <attribute name="processPrivateMem" >
      #          <value>5170739</value>
      #        </attribute>
      #        <attribute name="processSharedMem" >
      #          <value>0</value>
      #        </attribute>
      #      </attributes>
      #    </object>
      #
			# == exceptions
      # RuntimeError
      #  description: When no data has been colleted
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
      def stop_gpu_log(params={})
        params[:action] = 'stop'
        execute_info('gpu', params)
      end

      # == description
      # Load the cpu log without stopping the logging.
      #
			# == arguments
			# params
      #  Hash
      #   description: Optional params hash. If :clearLog => true given will clear the log when loading by default log will not be cleared.
			#   example: {:clearLog = true}
			#   default: nil
			#
      #
			# == returns
			# Xml
      #  description: data is returned in the same format as the ui state xml
      #  example: -
      #
			# == exceptions
      # RuntimeError
      #  description: When no data has been colleted
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
      def load_cpu_log(params={})
        params[:action] = 'load'
        execute_info('cpu', params)
      end

      # == description
      # Load the mem log without stopping the logging.
      #
			# == arguments
			# params
      #  Hash
      #   description: Optional params hash. If :clearLog => true given will clear the log when loading by default log will not be cleared.
			#   example: {:clearLog = true}
			#   default: nil
			#
      #
			# == returns
			# Xml
      #  description: data is returned in the same format as the ui state xml
      #  example: -
      #
			# == exceptions
      # RuntimeError
      #  description: When no data has been colleted
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
      def load_mem_log(params={})
        params[:action] = 'load'
        execute_info('mem', params)
      end

      # == description
      # Load the gpu log without stopping the logging.
      #
			# == arguments
			# params
      #  Hash
      #   description: Optional params hash. If :clearLog => true given will clear the log when loading by default log will not be cleared.
			#   example: {:clearLog = true}
			#   default: nil
			#
      #
			# == returns
			# Xml
      #  description: data is returned in the same format as the ui state xml
      #  example: -
      #
			# == exceptions
      # RuntimeError
      #  description: When no data has been colleted
      # ArgumentError
      #  description: For missing / wrong argument types
      #
			# == info
      #
        
      def load_gpu_log(params={})
        params[:action] = 'load'
        execute_info('gpu', params)
      end

      private

      def execute_info(service, params)
        begin

          validate_params(params)

          time = params[:interval].to_f
          interval = time*1000
          params[:interval] = interval.to_i

          command = MobyCommand::InfoLoggerCommand.new(service, params )

          ret = nil
          if self.class == MobyBase::SUT
            ret = execute_command( command )
          else
            command.application_id = get_application_id
            ret = @sut.execute_command( command )
          end

        rescue Exception => e
          MobyUtil::Logger.instance.log "behaviour","FAIL;Failed infologger \"#{params.to_s}\".;#{service};"
          Kernel::raise e
        end
        MobyUtil::Logger.instance.log "behaviour","PASS;Operation infologger succeeded with params \"#{params.to_s}\".;#{service};"
        ret
      end

      def validate_params(params)
        #type
        raise ArgumentError.new("Parameters must be a hash (e.g. {:filePath => 'C:\Data\',:interval => 1 }") unless params.kind_of?(Hash)
        if params[:action] == 'start'
          #speed
          raise ArgumentError.new("Log file path must be defined (e.g. :filePath => 'C:\Data\')") unless params[:filePath]
          #distance
          raise ArgumentError.new("Interval 1 must be an number (e.g. :interval => 1") unless params[:interval].kind_of?(Numeric)
        end
      end

      # enable hooking for performance measurement & debug logging
      MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


    end
  end
end
