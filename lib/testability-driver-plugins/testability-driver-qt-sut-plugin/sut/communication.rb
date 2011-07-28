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

    module Comms

      # Command types
      ERROR_MSG = 0
      VALID_MSG = 1
      OK_MESSAGE = "OK"

      class Inflator

        def self.inflate( response )

          # strip 4 extra bytes written by qt compression, return empty string if no raw data found, otherwise inflate it
          ( raw_data = response[ 4 .. -1 ] ).empty? ? "" : Zlib::Inflate.inflate( raw_data )

        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # Inflator

      # deprecated: see send_service_request#adapter.rb
      # Wrapper for protocol message.
      class QTResponse

        attr_accessor :msg_body, :flag, :crc, :message_id

        # deprecated: see send_service_request#adapter.rb
        # Initialize QT Response.      
        # == params
        # command_flag Indicator flad for message type (error or ok)
        # message_code 0 or an error code
        # msg_body Body of the message. For command a simple "OK" message for ui state the xml document as string  
        # == returns
        def initialize( command_flag, msg_body, crc, message_id )

          @flag, @msg_body, @crc, @message_id = command_flag, msg_body, crc, message_id

        end

        # deprecated: see send_service_request#adapter.rb
        def validate_message( msg_id )

          #check that response matches the request
          if @message_id != msg_id 

            msg = "Response to request did not match: #{ @message_id.to_s.inspect }!=#{ msg_id.to_s.inspect }"

            $logger.fatal msg

            $logger.fatal @msg_body 

            raise RuntimeError, msg

          end

          #raise error if error flag
          if @flag == Comms::ERROR_MSG

            raise MobyBase::ApplicationNotAvailableError, @msg_body if @msg_body =~ /The application with Id \d+ is no longer available/

            raise RuntimeError, @msg_body

          end

        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # QTResponse

      # Message generator for qt tas messages
      class MessageGenerator

        def self.generate( message_data, message_flag = VALID_MSG )

          MobyController::QT::Comms::QtMessage.new( message_flag, message_data )

        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # MobyController

      class QtMessage

        attr_reader :flag, :data, :compression, :size

        attr_accessor :message_id 

        def initialize( message_flag, message_data )

          # message flag
          @flag = message_flag

          # no compression by default
          @compression = 1

          @data = message_data

          @size = @data.size

          # calculate crc only when requested
          @crc = nil

        end

        def crc

          if @crc.nil?

            # calculate outgoing message crc; sent in message header to receiver for data validation
            @crc = TDriver::Checksum.crc16_ibm( @data ) 

          else

            @crc

          end
          
        end

        def make_binary_message( message_id )


          [ @flag, @size, crc, @compression, message_id, @data ].pack( 'CISCIa*' )

        end

        def deflate( level = 9 )

          unless @compression == 2

            @compression = 2

            data_size = @data.size

            # qUncompress required the data length at the beginning so append it - the bytes need to be arranged in the below method (see QByteArray::qUncompress)
            @data = [ ( data_size & 0xff000000 ) >> 24, ( data_size & 0x00ff0000 ) >> 16, ( data_size & 0x0000ff00 ) >> 8, ( data_size & 0x000000ff ), Zlib::Deflate.deflate( @data, level ) ].pack('C4a*')

            # update data size
            @size = @data.size

            # recalculate crc
            @crc = nil

          end
          
        end      

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # QtMessage

    end # Comms

  end # QT

end # MobyController
