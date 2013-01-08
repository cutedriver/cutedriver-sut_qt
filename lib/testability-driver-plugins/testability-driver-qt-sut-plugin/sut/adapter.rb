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
    
    # Sut adapter that used TCP/IP connections to send and receive data from QT side. 
    class SutAdapter < MobyController::SutAdapter
      
      attr_reader(
        :sut_id,
        :socket_received_bytes,
        :socket_sent_bytes,
        :socket_received_packets,
        :socket_sent_packets
      )

      attr_accessor(
        :socket_read_timeout,
        :socket_write_timeout,
        :socket_connect_timeout,
        :deflate_service_request,
        :deflate_minimum_size,
        :deflate_compression_level
      )
      
      # TODO: better way to set the host and port parameters   
      # Initialize the tcp adapter for communicating with the device.
      # Communication is done using two tcp channels one form commanding
      # the device and one for receiving ui state data.
      # UI state data receivin is done in a seprate thread so it is good
      # once usage is complete the shutdown_comms is called
      # == params
      # sut_id id for the sut so that client details can be fetched from params
      def initialize( sut_id, receive_timeout = 25, send_timeout = 25, connect_timeout = 25 )

        # reset socket
        @socket = nil

        # connection state is false by default
        @connected = false

        # store sut id
        @sut_id = sut_id

        # reset hooks - no hooks by default
        @hooks = {}

        # reset sent/received bytes and packets counters
        @socket_received_bytes = 0
        @socket_sent_bytes = 0

        @socket_received_packets = 0
        @socket_sent_packets = 0

        # set timeouts
        @socket_read_timeout = receive_timeout
        @socket_write_timeout = send_timeout
        @socket_connect_timeout = connect_timeout

        # randomized value for initial message packet counter
        @counter = rand( 1000 )

        # optimization - use local variables for less AST lookups
        @tcp_socket_select_method = TCPSocket.method( :select )

        @tdriver_checksum_crc16_ibm_method = TDriver::Checksum.method( :crc16_ibm )

        # retrieve sut configuration
        _sut_parameters = $parameters[ @sut_id ]

        # determine which inflate method to use
        if _sut_parameters[ :win_native, false ].to_s.true?

          @inflate_method = method( :inflate_windows_native )

        else

          @inflate_method = method( :inflate )

        end

        # default size 1kb
        @deflate_minimum_size = _sut_parameters[ :io_deflate_minimum_size_in_bytes, 1024 ].to_i

        # enabled by default - deflate outgoing service request if size > deflate_minimum_size
        @deflate_service_request = _sut_parameters[ :io_deflate_service_request, true ].true? 

        # retrieve default compression level - best compression by default
        @deflate_compression_level = _sut_parameters[ :io_deflate_compression_level, 9 ].to_i

      end

      # TODO: document me
      def disconnect

        # disconnect socket only if connected
        @socket.close if @connected

        @connected = false

      end

      def timeout_capable_socket_opener(ip,port,timeout=nil)
        addr = Socket.getaddrinfo(ip, nil)
        sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)
        if timeout
           secs = Integer(timeout)
           usecs = Integer((timeout - secs) * 1_000_000)
           optval = [secs, usecs].pack("l_2")
           ## actual timeout gets triggered after 2 times of "timeout" value, most likely because my patch applies timeout to read AND write ..
           sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
           sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
           ## also, worth checking if there's actually some Socket::SO_*  that applies the timeout to connection forming ..
        end
        begin
           sock.connect_nonblock(Socket.pack_sockaddr_in(port, addr[0][3]))
        rescue Errno::EINPROGRESS
           resp = IO.select([sock],nil, nil, timeout.to_i)
           begin
              sock.connect_nonblock(Socket.pack_sockaddr_in(port, addr[0][3]))
           rescue Errno::EISCONN
           end
        end
        sock ## Its also worth noting that if we set RCV AND SNDTIMEOT to some value when checking for established socket,
             ## it might make sense to set the defaults values back again so that only during the connection, timeout is
             ## different..
      end

      # TODO: document me
      def connect( id = nil )

        id ||= @sut_id

        sut_parameters = $parameters[ id, {} ]

        begin

          # retrieve ip and verify that value is not empty or nil
          ip = sut_parameters[ :qttas_server_ip, nil ].not_blank( 'Connection failure; QTTAS server IP not defined in SUT configuration' ).to_s

          # retrieve port and verify that value is not empty or nil
          port = sut_parameters[ :qttas_server_port, nil ].not_blank( 'Connection failure; QTTAS server port not defined in SUT configuration' ).to_i

          # executes the code block before openning the connection
          execute_hook( 'before_connect', id, ip, port ) if hooked?( 'before_connect' ) 

          # open tcp/ip connection
          # Using ruby TCPSocket this way will utilize the underlying kernel to do the timeout, which by default is too long (In my tests, on ubuntu 10.10, TCPSocket.open
          # will wait for exactly 380 seconds before throwing exception which is *FAR* too long ..
          @socket = TCPSocket.open( ip, port )


          # open tcp/ip connectio
          ## The block will actually double the time, so halve it. Actual timeout will +1 if it's an odd number
#          @socket = timeout_capable_socket_opener(ip,port,(@socket_connect_timeout.to_i / 2.0).ceil)

          # set connected status to true
          @connected = true

          # communication authentication etc can be done here
          execute_hook( 'after_connect', id, ip, port, @socket ) if hooked?( 'after_connect' ) 

        rescue

          execute_hook( 'connection_failed', id, ip, port, $! ) if hooked?( 'connection_failed' ) 
          #If reporter active report connetion error          
          
          raise IOError, "Connection failure; verify that QTTAS server is up and running at #{ ip }:#{ port }.\n Nested exception: #{ $!.message }"

        end

        true

      end

      # TODO: document me
      def group?

        @_group

      end

      # Set the document builder for the grouped behaviour message.
      def set_message_builder( builder )

        @_group = true

        @_builder = builder

      end

      # TODO: document me
      def append_command( node_list )

        node_list.each { | child | 

          @_builder.doc.root.add_child( child )

        }

      end

      # Sends a grouped command message to the server. Sets group to false and nils the builder
      # to prevent future behviours of being grouped (unless so wanted)
      # == returns    
      # the amout of commands grouped (and send)
      def send_grouped_request

        @_group = false

        size = @_builder.doc.root.children.size

        send_service_request(

          Comms::MessageGenerator.generate( @_builder.to_xml )

        )

        @_builder = nil

        size

      end

      def connected?

        @connected

      end

      # Send the message to the qt server         
      # If there is no exception propagated the send to the device was successful
      # == params   
      # message:: message in qttas protocol format   
      # == returns    
      # the response body
      def send_service_request( message, return_checksum = false )

        read_message_id = 0

        header = nil

        body = nil

        crc = nil

        connect if !@connected

        # increase message count
        @counter += 1

        # set request message id
        message.message_id = @counter

        # deflate message body
        if @deflate_service_request == true

          # do not deflate messages below 1kb
          message.deflate( @deflate_compression_level ) unless message.size < @deflate_minimum_size

        end

        # generate binary message to be sent to socket
        binary_message = message.make_binary_message( @counter )

        # write request message to socket
        write_socket( binary_message )

        until read_message_id == @counter
        
          # read message header from socket, unpack string to array
          # header[ 0 ] = command_flag
          # header[ 1 ] = body_size
          # header[ 2 ] = crc
          # header[ 3 ] = compression_flag
          # header[ 4 ] = message_id
          header = read_socket( 12 ).unpack( 'CISCI' )

          # read message body from socket
          body = read_socket( header[ 1 ] )

          # calculate body crc16 checksum
          crc = @tdriver_checksum_crc16_ibm_method.call( body )

          # read the message body and compare crc checksum
          raise IOError, "CRC checksum did not match, response message body is corrupted! (#{ crc } != #{ header[ 2 ] })" if crc != header[ 2 ]
          
          # validate response message; check that response message id matches the request
          # if smaller than expected try to read the next message but if bigger raise error
          read_message_id = header[ 4 ]

          if read_message_id < @counter

            $logger.warning "Response to request did not match: \"#{ header[ 4 ].to_s }\"<\"#{ @counter.to_s }\""

          elsif read_message_id > @counter

            $logger.fatal "Response to request did not match: \"#{ header[ 4 ].to_s }\">\"#{ @counter.to_s }\""

            # save to file?
            $logger.fatal body

            raise RuntimeError, "Response to request did not match: \"#{ header[ 4 ].to_s }\"!=\"#{ @counter.to_s }\""

          end
          
        end
      
        # inflate the message body if compressed
        body = @inflate_method.call( body ) if ( header[ 3 ] == 2 )

        # raise exception if messages error flag is set
        # Flag statuses:
        #   0 -> ERROR_MSG
        #   1 -> VALID_MSG
        #   2 -> OK_MESSAGE
        if header[ 0 ] == 0

          if body =~ /The application with Id \d+ is no longer available/

            raise MobyBase::ApplicationNotAvailableError, body

          else

            raise RuntimeError, body

          end

        end

        # return the body and checksum if required
        return_checksum ? [ body, body.hash ] : body

      end

    private

      def wait_for_data_available( bytes_count )
        # verify that there is data available to be read, timeout is not reliable on all platforms, loop instead
        time = 0
        readable = nil
        while (!readable && time < @socket_read_timeout) 
          readable = IO.select([ @socket ], nil, nil, 0.25)
          time = time + 0.25
        end
        
        raise IOError, "Socket reading timeout (#{ @socket_read_timeout.to_s }) exceeded for #{ bytes_count.to_i } bytes" if readable.nil?
      end

      def wait_for_data_sent( bytes_count )
        # verify that there is no data in writing buffer, timeout is not reliable on all platforms, loop instead
        time = 0
        writable = nil
        while (!writable && time < @socket_write_timeout) 
          writable = IO.select(nil,[ @socket ], nil, 0.25)
          time = time + 0.25
        end
        
        raise IOError, "Socket writing timeout (#{ @socket_write_timeout.to_s }) exceeded for #{ bytes_count.to_i } bytes" if writable.nil?
      end


      # TODO: document me
      def read_socket( bytes_count )

        # use local variables, performing less ATS (Abstract Syntax Tree) calls
        _socket_read_timeout = @socket_read_timeout

        # store time before start receving data
        start_time = Time.now

        # verify that there is data available to be read 
        wait_for_data_available( bytes_count )

        # read data from socket
        read_buffer = @socket.read( bytes_count ){

          raise IOError, "Socket reading timeout (#{ _socket_read_timeout.to_i }) exceeded for #{ bytes_count.to_i } bytes" if ( Time.now - start_time ) > _socket_read_timeout

        }

        # useless?
        raise IOError, "Socket reading error for #{ bytes_count.to_i } bytes - No data retrieved" if read_buffer.nil?

        @socket_received_bytes += read_buffer.size

        @socket_received_packets += 1

        read_buffer

      end

      # TODO: document me
      def write_socket( data )

        @socket.write( data )

        # verify that there is no data in writing buffer 
        wait_for_data_sent( data.length )
 
        @socket_sent_bytes += data.size

        @socket_sent_packets += 1

      end

    private

      # inflate to be used in native windows env.
      def inflate_windows_native( body )

        unless body.empty?
		
          zstream = Zlib::Inflate.new( -Zlib::MAX_WBITS )
          body = zstream.inflate( body )
          zstream.finish
          zstream.close

        end 

        body

      end

      # inflate to be used by default
      def inflate( body )

        # remove leading 4 bytes
        tmp = body[ 4 .. -1 ]

        unless tmp.empty?
		
          tmp = Zlib::Inflate.inflate( tmp )
          
        end

        tmp

      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # SutAdapter

  end # QT

end # MobyController
