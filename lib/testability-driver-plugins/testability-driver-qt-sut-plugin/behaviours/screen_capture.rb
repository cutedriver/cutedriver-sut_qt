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
    # ScreenCapture specific behaviours
    #
    # == behaviour
    # QtScreenCapture
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
		module ScreenCapture

			include MobyBehaviour::QT::Behaviour

			# Captures an object to a file. This can be used on widget or the whole application
			# == params
			#  
			# == returns  
			# nil
			# == raises
			# TestObjectNotFoundError:: If a graphics item is not visible on screen
			# ArgumentError:: If the text is not a string.
			# === examples
			#  @object.screen_capture    
			def capture_screen( format = "PNG", file_name = nil, draw = false )

				ret = nil

				begin

					# convert string representation of draw value to boolean
					draw = ( draw.downcase == 'true' ? true : false ) if draw.kind_of?( String )

					# verify that image format is type of string
					Kernel::raise ArgumentError.new( "Unexpected argument type (%s) for image format, expected %s" % [ format.class, "String" ] ) unless format.kind_of?( String )

					# verify that filename is type of string
					Kernel::raise ArgumentError.new( "Unexpected argument type (%s) for filename, expected %s" % [ file_name.class, "String" ] ) unless file_name.nil? || file_name.kind_of?( String )

					# verify that draw flag is type of boolean
					Kernel::raise ArgumentError.new( "Unexpected argument type (%s) for draw flag, expected %s" % [ draw.class, "boolean (TrueClass or FalseClass)" ] ) unless [ TrueClass, FalseClass ].include?( draw.class )

					command = command_params #in qt_behaviour
					command.command_name( 'Screenshot' )
					command.command_params( 'format'=>format, 'draw' => draw.to_s )
					command.set_require_response( true )
					command.transitions_off
					command.service( 'screenShot' )

					image_binary = @sut.execute_command( command )

					File.open(file_name, 'wb:binary'){ | image_file | image_file << image_binary } if ( file_name )

				rescue Exception => e

					#MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed capture_screen with format \"#{format}\", file_name \"#{file_name}\".;#{ identity };capture_screen;"

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed capture_screen with format \"%s\", file_name \"%s\".;%s;capture_screen;" % [ format, file_name, identity ]

					Kernel::raise e

				end

				#MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation capture_screen executed successfully with format \"#{format}\", file_name \"#{file_name}\".;#{ identity };capture_screen;"
				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation capture_screen executed successfully with format \"%s\", file_name \"%s\".;%s;capture_screen;" % [ format, file_name, identity ]

				image_binary

			end


			# Returns the coordinates where the given image is found on the device screen.
			#
			# === params
			# image_or_path:: The image to be searched for on the screen, can be either a RMagick Magic::Image, Magic::ImageList or a path to an image.
			# tolerance:: Integer defining the maximum percentage difference in RGB value when compared to maximum values where two pixels are still considered to be equal.
			# === returns
			# Array:: Array containing x and y coordinates as Integers, or nil if the image cannot be found on the screen. 
			# === throws
			# ArgumentError:: image_or_path was not of one of the allowed image types or a non empty String, or tolerance was not an Integer in the [0,100] range.
			def find_on_screen( image_or_path, tolerance = 0 )

			# RuntimeError:: No image could be loaded from the path given in image_or_path
				begin

					require 'RMagick'

					Kernel::raise ArgumentError.new("The tolerance argument was not an Integer in the [0,100] range.") unless tolerance.kind_of? Integer and tolerance >= 0 and tolerance <= 100

					target = nil

					if image_or_path.kind_of? Magick::Image

						target = image_or_path

					elsif image_or_path.kind_of? Magick::ImageList

						Kernel::raise ArgumentError.new("The supplied ImageList argument did not contain any images.") unless image_or_path.length > 0
						target = image_or_path

					elsif image_or_path.kind_of? String and !image_or_path.empty?

						begin
							target = Magick::ImageList.new(image_or_path)
						rescue        
							Kernel::raise RuntimeError.new("Could not load target for image comparison from path: \"#{image_or_path.to_s}\".")
						end

					else
						Kernel::raise ArgumentError.new("The image_or_path argument was not of one of the allowed image types or a non empty String.")
					end

					begin      
						screen = Magick::Image.from_blob(capture_screen){ self.format = "PNG" }.first
						screen.fuzz = tolerance.to_s + "%"
					rescue
						Kernel::raise RuntimeError.new("Failed to capture SUT screen for comparison. Details:\n" << $!.message)  
					end

					result = screen.find_similar_region( target )

				rescue Exception => e

					MobyUtil::Logger.instance.log "behaviour", 
						"FAIL;Failed when searching for image on the screen.;#{ identity };find_on_screen;#{(image_or_path.respond_to?(:filename) ? image_or_path.filename : image_or_path.to_s)},#{tolerance.to_s}"  

					Kernel::raise e

				end

				MobyUtil::Logger.instance.log "behaviour", 
					"PASS;Image search completed successfully.;#{ identity };find_on_screen;#{(image_or_path.respond_to?(:filename) ? image_or_path.filename : image_or_path.to_s)},#{tolerance.to_s}"

				result

			end

			# Verifies if the given image is found on the device screen.
			#
			# === params
			# image_or_path:: The image to be searched for on the screen, can be either a RMagick Magic::Image, Magic::ImageList or a path to an image.
			# tolerance:: Integer defining the maximum difference in RGB value where two pixels are still considered to be equal.
			# === returns
			# Boolean:: true if the given image is found on the device screen. 
			# === throws
			# ArgumentError:: image_or_path was not of one of the allowed image types or a non empty String, or tolerance was not an Integer in the [0,100] range.
			# RuntimeError:: No image could be loaded from the path given in image_or_path
			def screen_contains?( image_or_path, tolerance = 0 )

				begin
					# find_on_screen returns nil if the image is not found on the device screen
					result = !find_on_screen(image_or_path, tolerance).nil?
				rescue Exception => exc

					MobyUtil::Logger.instance.log "behaviour", 
						"FAIL;Failed when searching for image on the screen.;#{ identity };screen_contains?;#{(image_or_path.respond_to?(:filename) ? image_or_path.filename : image_or_path.to_s)},#{tolerance.to_s}"

					Kernel::raise exc


				end      

				MobyUtil::Logger.instance.log "behaviour", 
					"PASS;Image search completed successfully.;#{ identity };screen_contains?;#{(image_or_path.respond_to?(:filename) ? image_or_path.filename : image_or_path.to_s)},#{tolerance.to_s}"

				result

			end

			# enable hooking for performance measurement & debug logging
			MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


		end

	end
end
