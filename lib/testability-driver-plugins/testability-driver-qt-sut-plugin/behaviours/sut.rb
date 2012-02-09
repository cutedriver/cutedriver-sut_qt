# -*- coding: utf-8 -*-
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

# use tdrivers own xml api instead of nokogiri
#require 'nokogiri'

module MobyBehaviour

  module QT

    # == description
    # Qt SUT specific behaviours
    #
    # == behaviour
    # QtSUT
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
    # sut
    #
    module SUT

      include MobyBehaviour::Behaviour

      @@_event_type_map = { :Mouse => '0', :Touch => '1', :Both => '2' }

      # == description
      # Kills all of the applications started through the server.
      # == returns
      # NilClass
      #  description: -
      #  example: -      
      def kill_started_processes

        # execute the application control service request
        execute_command( MobyCommand::Application.new( :KillAll ) )
        nil
      end

      # == description
      # Returns XML list of applications running on SUT known to qttasserver
      # \n
      # == arguments
      #
      # == returns
      # String
      #   description: tasMessage XML
      #   example: <tasMessage dateTime="2010.10.26 17:01:53.930" version="0.9.1" ><tasInfo id="1" name="Qt4.7.0" type="qt" ><object id="" name="QApplications" type="applications" ></object></tasInfo></tasMessage>
      #
      # == exceptions
      # RuntimeError
      #   description: if getting applications list throws any exception it's converted to RuntimeError with descriptive message
      def list_apps

        apps = nil

        begin
          # execute the application control service request
          apps = execute_command( MobyCommand::Application.new( :ListApps ) )
          $logger.behaviour "PASS;Successfully listed applications.;#{ id };sut;{};list_apps;"

        rescue Exception => e

          $logger.behaviour "FAIL;Failed to list applications.;#{ id };sut;{};list_apps;"
          raise RuntimeError, "Unable to list applications: Exception: #{ e.message } (#{ e.class })"

        end

        apps     

      end

      # == description
      # Returns XML list of processes running in the target.
      # \n
      # == arguments
      #
      # == returns
      # String
      #   description: tasMessage XML
      #
      # == exceptions
      # RuntimeError
      #   description: if getting applications list throws any exception it's converted to RuntimeError with descriptive message
      def list_processes

        apps = nil

        begin
          # execute the application control service request
          apps = execute_command( MobyCommand::Application.new( :ListRunningProcesses ) )
          $logger.behaviour "PASS;Successfully listed processes.;#{ id };sut;{};list_processes;"

        rescue Exception => e

          $logger.behaviour "FAIL;Failed to list processes.;#{ id };sut;{};list_processes;"
          raise RuntimeError.new( "Unable to list processes: Exception: #{ e.message } (#{ e.class })" )

        end

        apps     

      end


      # == description
      # Returns XML list of applications and start times for applications started by qttasserver
      # \n
      # == arguments
      #
      # == returns
      # String
      #   description: tasMessage XML
      #   example: <tasMessage dateTime="2010.10.26 17:01:53.930" version="0.9.1" ><tasInfo id="1" name="Qt4.7.0" type="qt" ><object id="" name="QApplications" type="applications" ></object></tasInfo></tasMessage>
      #
      # == exceptions
      # RuntimeError
      #   description: if getting applications list throws any exception it's converted to RuntimeError with descriptive message
      def list_started_apps

        apps = nil

        begin
          # execute the application control service request
          apps = execute_command( MobyCommand::Application.new( :ListStartedApps ) )
          $logger.behaviour "PASS;Successfully listed applications.;#{ id };sut;{};list_started_apps;"

        rescue Exception => e

          $logger.behaviour "FAIL;Failed to list applications.;#{ id };sut;{};list_started_apps;"
          raise RuntimeError, "Unable to list started applications: Exception: #{ e.message } (#{ e.class })"

        end

        apps     

      end
      
      # == nodoc
      # NOT SUPPORTED ANYMORE
      def list_crashed_apps
    
        raise ArgumentError, 'Behaviour "list_crashed_apps" is no longer supported.'

      end

      # == description
      # Executes the command in a shell in the target sut. Note that the executable need to be in path or otherwise you need to use full absolute path. No relative paths can be used with this command. If the process started will take more than 4 seconds to exit then you should launch the process in detached mode by adding the parameter hash ":detached => 'true'" to the arguments. By default processes are launched in "synchronus" mode.
      #
      # == arguments
      # command
      #  String
      #   description: String containing the command executable to execute and any arguments it might need. Executable can be used without path if it is in PATH. Otherwise full absolute path is needed. A shell is required for piped commands (UNIX).
      #   example: "ruby script.rb" or 'sh -c "ruby script.rb|grep output'"
      #
      # param
      #  Hash
      #   description: Hash with the flags for the command
      #   example: {:wait => 'true', :timeout => 13}
      #
      # == tables
      # execute_shell_command_hash
      #  title: Parameter hash keys
      #  |Key|Description|Default|
      #  |:detached|Hash containing the ':detached' key with 'true' or 'false' strings as value.|false|
      #  |:threaded|If :thread is set true, the command will be run in a background thrad and the command will return the PID of the process. See [link="#QtSUT:shell_command"]shell_command[/link] for information about controlling the command.|false|
      #  |:wait|Execute a threaded command and wait for the command to complete. Return value will contain the output of the command. Use :wait if the shell command execution taks longer than 4 seconds.|false|
      #  |:timeout|Timeout for :wait, in seconds. If timeout is reached, the command will be killed. RunTimeError occurs if timeout is reached.|300|
      #
      # == returns
      # String
      #  description: Output of the command if any
      #  example: "OK"
      #
      # == Exceptions
      # ArgumentError
      #  description: The command argument was not a non empty String.
      # 
      # ArgumentError
      #  description: The parameters argumet must be a Hash.
      #
      # RuntimeError
      #  description: Timeout of %s seconds reached. %s
      def execute_shell_command(command, param = { :detached => "false"} )      

        raise ArgumentError, "The command argument must be a non empty String." unless command.kind_of?( String ) and !command.empty?
        raise ArgumentError, "The parameters argumet must be a Hash." unless param.kind_of?( Hash )

        if param[:detached].nil?
          param[:detached] = "false"
        end
            
        param[:timeout].nil? ? timeout = 300 : timeout = param[:timeout].to_i

        # Launch the program execution into the background, wait for it to finish.
        if param[:wait].to_s == "true"
          param[:threaded] = "true"

          #pid = execute_command( MobyCommand::Application.new( :Shell, command, nil, nil, nil, nil, nil, nil, param ) ).to_i

          pid = execute_command( MobyCommand::Application.new( :Shell, { :application_name => command, :flags => param } ) ).to_i
         
          data = "" 
          if pid != 0
            time = Time.new + timeout
            while true

              obj = shell_command(pid)

              sleep 1

              data += obj['output'].to_s # cast to string in case of output is nil

              if Time.new > time
                command_params = {:kill => 'true'}
                command_output = shell_command(pid, command_params)['output']
                raise RuntimeError, "Timeout of #{timeout.to_s} seconds reached. #{command_output}"
              elsif obj['status'] == "RUNNING"
                next
              else 
                break
              end

            end
          end
          return data
        end

        #return execute_command( MobyCommand::Application.new( :Shell, command, nil, nil, nil, nil, nil, nil, nil, param ) ).to_s

        return execute_command( MobyCommand::Application.new( :Shell, { :application_name => command, :flags => param } ) ).to_s

      end

      # == description
      # Control and retrieve data from a command started by [link="#QtSUT:execute_shell_command"]execute_shell_command[/link]. On a running process, the status and produced output is returned. The command will remove all output from the server that has already been retrieved by the testability driver script. If the command status is FINISHED, all information is removed from the server.
      #
      # == arguments
      # pid
      #  Integer
      #   description: Process id of the command returned by the threaded execute_shell_command.
      #   example: 23442 
      # 
      # param
      #  Hash
      #   description: Additional parameters for the command. Currently supported is ":kill", which will kill the process.
      #   example: {:kill => 'true'}
      #
      # == tables
      # shell_command_return_values
      #  title: Shell command return values
      #  |Key|Description|
      #  |status|RUNNING, ERROR, FINISHED|
      #  |output|Command output|
      #  |exitCode|Return code of the command if finished|
      #      
      # == returns
      # Hash
      #  description: The return hash will be empty if no pid is found.
      #  example: {:status => 'FINISHED', :output => 'example_output', :exitCode => 0}
      # 
      # == exceptions
      # ArgumentError
      #  description: The command argument was not a non empty String
      #
      def shell_command( pid, param = {} )

        raise ArgumentError, "pid argument should be positive integer." unless pid.to_i > 0

        param[ :status ] = 'true'

        xml_source = execute_command( 
          MobyCommand::Application.new( 
            :Shell, 
            { 
              :application_name => pid.to_s, 
              :flags => param 
            }
           )
        ).to_s

        if param[ :kill ].nil?


          object_xml_data, unused_rule = @test_object_adapter.get_objects( MobyUtil::XML.parse_string( xml_source ), { :type => 'Response' }, true )

=begin
          data = {}

          object_xml_data.collect{ | element |
          
            data.merge!( 

              @test_object_adapter.test_object_attributes( element ) 

            )

          }
=end
          object_xml_data.inject( {} ){ | result, element |

            result.merge!( @test_object_adapter.test_object_attributes( element ) )

          }

        else

          # Killed processes have no relevant data.
          {
            :status => "KILLED",
            :output => xml_source
          }

        end

      end


      # == description
      # launches application in symbian device based on UID and return launched application if succesfull.
      #
      # == arguments
      # target_application_hash
      #  Hash
      #   description: Hash defining expected attributes of the application
      #   example: { :UID => '' }
      #
      # == returns
      # MobyBase::Application
      #  description: launched application that matched the uid
      #  example: -
      #
      # == exceptions
      # TypeError
      #  description: Wrong argument type %s for attributes (expected Hash)
      #
      def launch_with_uid( target_application_hash = {} )

        begin

          target_application_hash.check_type Hash, 'wrong argument type $1 for application attributes (expected: $2)'
  
          the_uid =  "failed with uid:" + target_application_hash[ :UID ].to_s

          fullname = @sut.fixture( "launch", "launch_with_uid", target_application_hash )
          
          raise fullname if fullname == the_uid
          
          full_shortname = fullname.rpartition( '\\' )[ -1 ]
          
          shortname = full_shortname.rpartition( '.' )[ 0 ]
          
          app_child = @sut.application( :name => shortname )

        rescue

          $logger.behaviour "FAIL;Failed to find application.;#{ id.to_s };sut;{};application;#{ target_application_hash.inspect }"

          raise

        end

        $logger.behaviour "PASS;Application found.;#{ id.to_s };sut;{};application;#{ target_application_hash.inspect }"

        app_child

      end

      # == description
      # Returns details about the tested target. The data is platform/device specific which will make your scripts platform dependant. For devices with mobility apis the data available from them is returned and could be somewhat similar across platforms. Memory details are returned in a fixed format so they can be used and still maintain compatibility cross platforms. However it should be noted that platforms which do not support memory details will return -1 (scripts will not break but data will not be usable).
      # == arguments
      # == returns
      # MobyBase::StateObject
      #   description: Similar object to test objects.
      #   example: -
      # == exceptions
      def system_information

        # xml_source = execute_command( MobyCommand::Application.new( :SystemInfo, nil) )
        # @sut.state_object( xml_source )

        @sut.state_object( 
          execute_command( 
            MobyCommand::Application.new( :SystemInfo ) 
          )
        )

      end

      # == description
      # Returns the memory used by the qttassever in bytes. Note that this will query for the details from the device. If you intend to use all of the memory details see system_information on how to get the details in one query.
      # == arguments
      # == returns
      # Integer
      #   description: Memory usage in bytes, or -1 if there was an error
      #   example: 7376896
      # == exceptions
      def agent_mem_usage
        info = system_information
        begin 
          info.MemoryStatus.attribute('qttasMemUsage').to_i
        rescue Exception => e
          -1
        end
      end

      # == description
      # Returns the total amount of memory in bytes. Note that this will query for the details from the device. If you intend to all of the memory details see system_information on how to get the details in one query.
      # == arguments
      # == returns
      # Integer
      #   description: Amount of total memory, or -1 if there was an error
      #   example: 2147483647
      # == exceptions
      def system_total_mem
        info = system_information
        begin 
          info.MemoryStatus.attribute('total').to_i
        rescue Exception => e
          -1
        end
      end

      # == description
      # Returns the amount of available memory in bytes. Note that this will query for the details from the device. If you intend to use all of the memory details see system_information on how to get the details in one query.
      # == arguments
      # == returns
      # Integer
      #   description: Amount of available memory, or -1 if there was an error
      #   example: 1214980096
      # == exceptions
      def system_available_mem
        info = system_information
        begin 
          info.MemoryStatus.attribute('available').to_i
        rescue Exception => e
          -1
        end
      end

      # == description
      # Taps the SUT screen at the specified coordinates.\n
      # \n
      # [b]NOTE:[/b] Method is only implemented in *nix enviroments.
      #
      # == arguments
      # x
      #  Fixnum
      #   description: Target point vertical axis coordinate.
      #   example: 50
      # y
      #  Fixnum
      #   description: Target point horizontal axis coordinate.
      #   example: 100
      #
      # time_to_hold
      #  Float
      #   description: Duration of the tap, in seconds.
      #   example: 0.1
      #
      # == returns
      # NilClass
      #  description: Always returns nil
      #  example: -
      #
      def tap_screen( x, y, time_to_hold = 0.1 ) # todo count
    
        command = MobyCommand::Tap.new(x,y,time_to_hold)

        begin 
          execute_command( command )            
          nil
        rescue Exception
          
          $logger.behaviour "FAIL;Failed tap_screen on coords \"#{ x }:#{ y }\";"

          raise
          
        end      

      end

      # == nodoc
      # == description
      # Request the qttasserver to shutdown. This command will cause the qttasserver to close. The sut will no longer be usable after this command. To resume testing qttasserver must be restarted.
      # == returns
      # NilClass
      #  description: -
      #  example: -
      # == exceptions
      # RuntimeError
      #  description: Unable to close qttas: Exception: %s (%s) 
      def close_qttas
        begin
          # execute the application control service request
          execute_command( MobyCommand::Application.new( :CloseQttas ) )
          $logger.behaviour "PASS;Successfully closed qttas.;#{ id };sut;{};close_qttas;"
        rescue Exception => e
          $logger.behaviour "FAIL;Failed to close qttas.;#{ id };sut;{};close_qttas;"
          raise RuntimeError, "Unable to close qttas: Exception: #{ e.message } (#{ e.class })"
        end
        nil
      end

      # == nodoc
      # == description
      # Starts process memory logging. Information about the given application's
      # heap memory usage will be stored in a file. In addition to application,
      # used log file can be specified as well as the type of timestamp and
      # interval length (in seconds).\ŋ
      # \n
      # [b]NOTE:[/b] Currently only supported on Symbian platform.
      #
      # == arguments
      # thread_name
      #  String
      #   description: Name of the application process/thread.
      #   example: 'testapp'
      #
      # file_name
      #  String
      #   description: Full name (containing path) of the used log file.
      #   example: 'c:\Data\proc_mem.log'
      #
      # timestamp_type
      #  String
      #   description: Type of the used timestamp, either "absolute" for
      #                current system time or "relative" or not specified for
      #                relative timestamp from 0 in milliseconds.
      #   example: 'absolute'
      #
      # interval_s
      #  Integer
      #   description: Logging interval in seconds.
      #   example: 2
      #
      # == returns
      # String
      #   description: Response message
      #   example: 'OK'
      #
      def log_process_mem_start(thread_name, file_name = nil, timestamp_type = nil, interval_s = nil)
        status = nil
        begin

=begin
          status = execute_command(
                       MobyCommand::Application.new(
                                    :ProcessMemLoggingStart,
                                    thread_name,
                                    nil, nil, nil, nil, nil, nil,
                                    {:file_name => file_name, :timestamp => timestamp_type, :interval_s => interval_s} ) )
=end

          status = execute_command(
            MobyCommand::Application.new(
              :ProcessMemLoggingStart,
              { :application_name => thread_name, :flags => { :file_name => file_name, :timestamp => timestamp_type, :interval_s => interval_s } }
            ) 
          )

          $logger.behaviour "PASS;Successfully started process memory logging.;#{ id };sut;{};log_process_mem_start;"

        rescue Exception => e

          $logger.behaviour "FAIL;Failed to start process memory logging.;#{ id };sut;{};log_process_mem_start;"
          raise RuntimeError, "Unable to start process memory logging: Exception: #{ e.message } (#{ e.class })"

        end

        status

      end

      # == nodoc
      # == description
      # Stops process memory logging. Logging of the given application's heap memory usage is stopped. Either the full log file name or the log file
      # contents will be returned.\n
      # \n
      # [b]NOTE:[/b] Currently only supported on Symbian platform.
      #
      # == arguments
      # thread_name
      #  String
      #   description: Name of the application process/thread.
      #   example: 'testapp'
      #
      # return_data
      #  String
      #   description: Should the log file data be returned in response message.
      #                If false, only the log file name will be returned.
      #   example: 'true'
      #
      # == returns
      # String
      #   description: Either the full log file name or the log file contents.
      #   example: 'OK'
      #
      def log_process_mem_stop(thread_name, return_data = nil)
        log = nil
        begin

          log = execute_command(
            MobyCommand::Application.new(
              :ProcessMemLoggingStop,
              { :application_name => thread_name, :flags => { :return_data => return_data } } 
            ) 
          )

          $logger.behaviour "PASS;Successfully stopped process memory logging.;#{ id };sut;{};log_process_mem_stop;"
        rescue Exception => e
          $logger.behaviour "FAIL;Failed to stop process memory logging.;#{ id };sut;{};log_process_mem_stop;"
          raise RuntimeError, "Unable to stop process memory logging: Exception: #{ e.message } (#{ e.class })"
        end
        log
      end

      # == description
      # Starts generating CPU load. Tries to generate CPU load as accurately as
      # it can but depending on other activities on the system it might vary. \n
      # \n
      # [b]NOTE:[/b] Currently only supported on Symbian platform.
      #
      # == arguments
      # cpu_load
      #  Integer
      #   description: Requested CPU load in percentage.
      #   example: 50
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      def cpu_load_start( cpu_load )
        begin

=begin
          status = execute_command(
                      MobyCommand::Application.new(
                                 :CpuLoadStart,
                                 nil, nil, nil, nil, nil, nil, nil,
                                 {:cpu_load => cpu_load} ) )
=end

          status = execute_command(
            MobyCommand::Application.new(
              :CpuLoadStart,
              { :flags => { :cpu_load => cpu_load } } 
            ) 
          )

          $logger.behaviour "PASS;Successfully started generating CPU load.;#{ id };sut;{};cpu_load_start;"

        rescue Exception => e

          $logger.behaviour "FAIL;Failed to start generating CPU load.;#{ id };sut;{};cpu_load_start;"

          raise RuntimeError, "Unable to start generating CPU load: Exception: #{ e.message } (#{ e.class })"

        end

      end

      # == description
      # Stops generating CPU load.\n
      # \n
      # [b]NOTE:[/b] Currently only supported on Symbian platform.
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      def cpu_load_stop
        begin
          status = execute_command(MobyCommand::Application.new(:CpuLoadStop) )
          $logger.behaviour "PASS;Successfully started generating CPU load.;#{ id };sut;{};cpu_load_start;"
        rescue Exception => e
          $logger.behaviour "FAIL;Failed to start generating CPU load.;#{ id };sut;{};cpu_load_start;"
          raise RuntimeError, "Unable to start generating CPU load: Exception: #{ e.message } (#{ e.class })"
        end
      end

      # == description
      # Does MemSpy heap dump from the given application. The dump will be
      # saved in a file, which need to be separately fetched from the device.\n
      # \n
      # [b]NOTE:[/b] Only supported on Symbian platform.
      #
      # == arguments
      # thread_name
      #  String
      #   description: Name of the application thread.
      #   example: 'phonebook2'
      #
      # == returns
      # String
      #   description: Response message
      #   example: 'OK'
      #
      def dump_heap(thread_name)
        status = nil
        begin
          status = execute_command(MobyCommand::Application.new(
                                      :ThreadHeapDump,
                                      {:application_name => thread_name}
                                    )
                                  )
          $logger.behaviour "PASS;Successfully dumped thread heap.;#{ id };sut;{};dump_heap;"
        rescue Exception => e
          $logger.behaviour "FAIL;Failed to dump thread heap.;#{ id };sut;{};dump_heap;"
          raise RuntimeError, "Unable to dump thread heap: Exception: #{ e.message } (#{ e.class })"
        end
        status
      end

      # == description
      # Groups behaviours into a single message. Commands are executed in the target in sequence using the given interval as timeout between the commands. The interval is not quaranteed to be exactly the specified amount and will vary depending on the load in the target device. Therefore it is not recommended to use the interval as basis for the test results. The commands are all executed in the target device in a single roundtrip from TDriver to the target device so no verification will or can be done between the commands so do not group behaviours which change the ui in a way that the next command may fail. Best use cases for the grouping is static behaviours such as virtual keyboard button taps. Behaviours can only be qrouped for one application at a time and you need to provide the application object as parameter. Sut behaviours cannot be grouped.
      # == arguments
      # interval
      #  Fixnum
      #   description: Inteval time in seconds (0.1 is an acceptable value)
      #   example: 1
      # app
      #  MobyBase::TestObject
      #   description: The target application for the grouped behaviours
      #   example: -
      # &block
      #  Proc
      #   description: Code block containing the behaviours to group as one.
      #   example: {app.Object.tap;app.Object_two.tap}
      # == returns
      # NilClass
      #  description: -
      #  example: -
      def group_behaviours( interval, app, &block )
        begin      
          raise ArgumentError.new("Application must be defined!") unless app
          raise ArgumentError.new("Interval must be a number.") unless interval.kind_of?(Numeric)

          interval_millis = interval*1000 # to millis

          # make one refresh before execution then freeze
          find_object_state = parameter[ :use_find_object, false ]
          parameter[ :use_find_object] = false 

          app.force_refresh({:id => get_application_id})
          freeze

          #disable sleep to avoid unnecessary sleeping
          parameter[ :sleep_disabled ] = true

          ret = execute_command( MobyCommand::Group.new(interval_millis.to_i, app, block ) )

          parameter[ :sleep_disabled ] = false
          parameter[ :use_find_object] = find_object_state

          unfreeze

          # the behaviour returns the amout of behaviours
          # sleep to avoid sending messages to the app until the 
          # commands have been executed
          sleep ( ret * interval )

          $logger.behaviour "PASS;Successfully executed grouped behaviours.;#{ id };sut;{};group_behaviours;"
        rescue Exception => e
          $logger.behaviour "FAIL;Failed to execute grouped behaviours.;#{ id };sut;{};group_behaviours;"
          raise RuntimeError, "Unable to execute grouped behaviours: Exception: #{ e.message } (#{ e.class })"
        end
        nil
      end

      # == description
      # Set the event type used to interact with the target. Possible methods are :Mouse, :Touch and :Both.
      # Event generation depends on this setting. If set to :Mouse or :Touch then only those events are generated.
      # If set to :Both then both mouse and touch events are sent. In this situation touch events are set as primary.
      # This setting has no affect when using multitouch.\n\n 
      # [b]NOTE:[/b] If you generate multitouch type events e.g. a.tap_down, 
      # b.tap_down then a.tap_up, b.tap_up you must set the type to :Touch to avoid mouse events to be generated.
      # == arguments
      # new_type
      #  Symbol
      #   description: Symbol defining which method to use: :Mouse, :Touch and :Both.
      #   example: :Touch
      # == returns
      # NilClass
      #  description: -
      #  example: -
      # == raises
      # ArgumentError
      #  description: If invalid type is given.
      #
      def set_event_type(new_type)
         raise ArgumentError.new("Invalid event type. Accepted values :" << @@_event_type_map.keys.join(", :") ) unless @@_event_type_map.include?(new_type)
        $parameters[ id ][ :event_type] = @@_event_type_map[new_type]
        nil
      end

      # == nodoc
      # {:name => '', id => '', applicationUid => ''},[ {:objectName => '' , :className => , :text =>} ,..]
      def find_object( app_details = nil, objects = nil, checksum = nil )
        execute_command( MobyCommand::FindObjectCommand.new( self, app_details, objects, checksum ) )
      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
    end 

  end

end
