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

require 'zlib'

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
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

			end

			# Wrapper for protocol message.
			class QTResponse

				attr_accessor :msg_body, :flag, :crc, :message_id

				# Initialize QT Response.      
				# == params
				# command_flag Indicator flad for message type (error or ok)
				# message_code 0 or an error code
				# msg_body Body of the message. For command a simple "OK" message for ui state the xml document as string  
				# == returns
				def initialize( command_flag, msg_body, crc, message_id )

					@flag, @msg_body, @crc, @message_id = command_flag, msg_body, crc, message_id

				end

				def validate_message(msg_id)				  

					#check that response matches the request
					if @message_id != msg_id 
						MobyUtil::Logger.instance.log "fatal" , "Response to request did not match: \"#{@message_id}\"!=\"#{msg_id.to_s}\""
						MobyUtil::Logger.instance.log "fatal" , @msg_body 
						raise RuntimeError.new("Response to request did not match: \"#{@message_id}\"!=\"#{msg_id.to_s}\"") 
					end

					#raise error if error flag
					raise RuntimeError.new( @msg_body ) if flag == Comms::ERROR_MSG

				end

				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

			end #class

			# Message generator for qt tas messages
			class MessageGenerator

				def self.generate( message_data, message_flag = VALID_MSG )

					MobyController::QT::Comms::QtMessage.new( message_flag, message_data )

				end

				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

			end

			class QtMessage

				attr_reader :flag, :data, :crc
				attr_accessor :message_id 

				def initialize( message_flag, message_data )
				    @compression = 1
				    @data = message_data
				    deflate if @data.length > 1000
					@flag, @crc = message_flag, CRC::Crc16.crc16_ibm( @data, 0xffff )
				end

				def make_binary_message
					Kernel::raise ArgumentError.new( "Message cannot be nil" ) unless @message_id
					[ @flag, @data.size, @crc, compression, @message_id, @data ].pack( 'CISCIa*' )
				end

				def compression
					@compression
				end           

				def deflate
				  @compression = 2
				  #qUncompress required the data length at the beginning so append it
				  #the bytes need to be arranged in the below method (see QByteArray::qUncompress)
				  @data = [(@data.size & 0xff000000) >> 24, (@data.size & 0x00ff0000) >> 16,
				           (@data.size & 0x0000ff00) >> 8, (@data.size & 0x000000ff),
  		                    Zlib::Deflate.deflate( @data, 9)].pack('C4a*')
				end			

				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

			end # class

		end # module Comms

	end
end
