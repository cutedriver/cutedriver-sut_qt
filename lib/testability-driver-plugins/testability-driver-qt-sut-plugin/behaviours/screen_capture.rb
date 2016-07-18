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

      # == description
			# Captures an object to a file. This can be used on widget or the whole application
			# == arguments
      # format
      #  String
      #   description: Image format for output file (currently only PNG supported)
      #   example: "PNG"
      #   default: "PNG"
      #
      # file_name
      #  String
      #   description: Filename of output image with/without absolute or relative path.
      #   example: output_image.png
      #   example: my_relative_folder/output_image.png
      #   example: c:/my_windows_folder/output_image.png
      #   example: ~/my_linux_folder/output_image.png
			#   default: nil
      #
      # draw
      #  Boolean
      #  description:	When set to true repaint signal is sent to object before capturing the bitmap.
      #  example: true
      #  default: false
      #  
			# == returns
			# String
      #  description:	Image binary
      #  example: File.open("image.PNG", 'wb:binary') { |f2| f2.puts @screen_capture_data }
      #  
			# == exceptions
			# TestObjectNotFoundError
      #  description: If a graphics item is not visible on screen
			# ArgumentError
      #  description: If the text is not a string.
			#
			def capture_screen( format = "PNG", file_name = nil, draw = false )

				ret = nil

				begin

					# convert string representation of draw value to boolean
					draw = ( draw.downcase == 'true' ? true : false ) if draw.kind_of?( String )

					# verify that image format is type of string
					raise ArgumentError.new( "Unexpected argument type (%s) for image format, expected %s" % [ format.class, "String" ] ) unless format.kind_of?( String )

					# verify that filename is type of string
					raise ArgumentError.new( "Unexpected argument type (%s) for filename, expected %s" % [ file_name.class, "String" ] ) unless file_name.nil? || file_name.kind_of?( String )

					# verify that draw flag is type of boolean
					raise ArgumentError.new( "Unexpected argument type (%s) for draw flag, expected %s" % [ draw.class, "boolean (TrueClass or FalseClass)" ] ) unless [ TrueClass, FalseClass ].include?( draw.class )

					command = command_params #in qt_behaviour
					command.command_name( 'Screenshot' )
					command.command_params( 'format'=>format, 'draw' => draw.to_s )
					command.set_require_response( true )
					command.transitions_off
					command.service( 'screenShot' )

					image_binary = @sut.execute_command( command )

					File.open(file_name, 'wb:binary'){ | image_file | image_file << image_binary } if ( file_name )

				rescue Exception => e

					#$logger.behaviour "FAIL;Failed capture_screen with format \"#{format}\", file_name \"#{file_name}\".;#{ identity };capture_screen;"

					$logger.behaviour "FAIL;Failed capture_screen with format \"%s\", file_name \"%s\".;%s;capture_screen;" % [ format, file_name, identity ]

					raise e

				end

				#$logger.behaviour "PASS;Operation capture_screen executed successfully with format \"#{format}\", file_name \"#{file_name}\".;#{ identity };capture_screen;"
				$logger.behaviour "PASS;Operation capture_screen executed successfully with format \"%s\", file_name \"%s\".;%s;capture_screen;" % [ format, file_name, identity ]

				image_binary

			end


      # == description
			# Searches the SUT screen for the given image and returns top left coordinates if a match is found. Alternatively the search can be limited to only parts of the display by calling this method for a widget.
			#
			# == arguments
			# image_or_path
      #  String
      #   description: Path to image being searched for. Must not be empty.
      #   example: 'image_data/icon_help.png'
      #  Magick::Image
      #   description: RMagick Image object to be searched for. You must 'require rmagick' in your script prior to using this.
      #   example: Magick::Image.read('image_data/icon_help.png').first
      #  Magick::ImageList
      #   description: RMagick ImageList object where the current image is the one to be searched for. You must 'require rmagick' in your script prior to using this.
      #   example: Magick::ImageList.new('image_data/icon_help.png')
      #
			# tolerance
      #  Integer
      #  description: Integer defining the maximum percentage difference in RGB value when compared to maximum values where two pixels are still considered to be equal.
      #  example: 20
      #  default: 0
			# == returns
			# Array
      #  description: Array containing x and y coordinates as Integers, or nil if the image cannot be found on the screen.
      #  example: [24,50]
      # Nil
      #  description: The image could not be found
      #  example: -
      #  
			# == exceptions
			# ArgumentError
      #  description: image_or_path was not of one of the allowed image types or a non empty String, or tolerance was not an Integer in the [0,100] range.
      # RuntimeError
      #  description: No image could be loaded from the path given in image_or_path
      #
			def find_on_screen( image_or_path, tolerance = 0 )

			# RuntimeError:: No image could be loaded from the path given in image_or_path
				begin

					require 'rmagick'

					raise ArgumentError.new("The tolerance argument was not an Integer in the [0,100] range.") unless tolerance.kind_of? Integer and tolerance >= 0 and tolerance <= 100

					target = nil

					if image_or_path.kind_of? Magick::Image

						target = image_or_path

					elsif image_or_path.kind_of? Magick::ImageList

						raise ArgumentError.new("The supplied ImageList argument did not contain any images.") unless image_or_path.length > 0
						target = image_or_path

					elsif image_or_path.kind_of? String and !image_or_path.empty?

						begin
							target = Magick::ImageList.new(image_or_path)
						rescue        
							raise RuntimeError.new("Could not load target for image comparison from path: \"#{image_or_path.to_s}\".")
						end

					else
						raise ArgumentError.new("The image_or_path argument was not of one of the allowed image types or a non empty String.")
					end

					begin      
						screen = Magick::Image.from_blob(capture_screen){ self.format = "PNG" }.first
						screen.fuzz = tolerance.to_s + "%"
					rescue
						raise RuntimeError.new("Failed to capture SUT screen for comparison. Details:\n" << $!.message)  
					end

					result = screen.find_similar_region( target )

				rescue Exception => e

					$logger.behaviour "FAIL;Failed when searching for image on the screen.;#{ identity };find_on_screen;#{(image_or_path.respond_to?(:filename) ? image_or_path.filename : image_or_path.to_s)},#{tolerance.to_s}"  

					raise e

				end

				$logger.behaviour "PASS;Image search completed successfully.;#{ identity };find_on_screen;#{(image_or_path.respond_to?(:filename) ? image_or_path.filename : image_or_path.to_s)},#{tolerance.to_s}"

				result

			end

      # == description
			# Verifies if the given image is found on the device screen. Alternatively the verification can be limited to only parts of the display by calling this method for a widget.
			#
			# == arguments
			# image_or_path
      #  String
      #   description: Path to image being searched for. Must not be empty.
      #   example: 'image_data/icon_help.png'
      #  Magick::Image
      #   description: RMagick Image object to be searched for. You must 'require rmagick' in your script prior to using this.
      #   example: Magick::Image.read('image_data/icon_help.png').first
      #  Magick::ImageList
      #   description: RMagick ImageList object where the current image is the one to be searched for. You must 'require rmagick' in your script prior to using this.
      #   example: Magick::ImageList.new('image_data/icon_help.png')
      #
			# tolerance
      #  Integer
      #  description: Integer defining the maximum percentage difference in RGB value when compared to maximum values where two pixels are still considered to be equal.
      #  example: 20
      #  default: 0
      #
			# == returns
			# Boolean
      #  description: true if the given image is found on the device screen.
      #  description: false if the image was not found on the screen.
      #  example: true
      #
			# == exceptions
			# ArgumentError
      #  description: image_or_path was not of one of the allowed image types or a non empty String, or tolerance was not an Integer in the [0,100] range.
			# RuntimeError
      #  description: No image could be loaded from the path given in image_or_path
			def screen_contains?( image_or_path, tolerance = 0 )

				begin
					# find_on_screen returns nil if the image is not found on the device screen
					result = !find_on_screen(image_or_path, tolerance).nil?
				rescue Exception => exc

					$logger.behaviour	"FAIL;Failed when searching for image on the screen.;#{ identity };screen_contains?;#{(image_or_path.respond_to?(:filename) ? image_or_path.filename : image_or_path.to_s)},#{tolerance.to_s}"

					raise exc


				end      

				$logger.behaviour "PASS;Image search completed successfully.;#{ identity };screen_contains?;#{(image_or_path.respond_to?(:filename) ? image_or_path.filename : image_or_path.to_s)},#{tolerance.to_s}"

				result

			end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )


		end

	end
end
