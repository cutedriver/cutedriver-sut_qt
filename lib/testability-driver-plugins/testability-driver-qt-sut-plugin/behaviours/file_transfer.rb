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
    # This module contains implementation to control sut file transfers
    #
    # == behaviour
    # FileTransfer
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
    # sut
    #
		module FileTransfer

			include MobyBehaviour::QT::Behaviour

      # == description
      # Delete files from sut \n
      #      
      #
			# == arguments
			# arguments
      #  Hash
      #   description: Hash containing parameters to be used in file transfer
			#   example: Following symbols are supported
			#   [:file]
			#   [:from]
			#   [:dir]
      #
			# == returns
			# Array
      #  description: Deleted files
      #  example: ["/dir/file.txt","/dir/file2.txt"]
      #
			# == exceptions
			# ArgumentErrors
      #  description: For missing / wrong argument types
      #
			# == info			
      #
      def delete_from_sut( arguments )

        arguments.check_type Hash, "wrong argument type $1 for #{ __method__.to_s } method (expected $2)"

        if arguments.include?( :file )

          file=arguments[ :file ].gsub('\\','/')
          device_path=arguments[ :from ].gsub('\\','/') if arguments.include?(:from)

          if device_path!=nil

            ret_list_of_files = []
            list_of_files = list_files_from_sut(:from=>device_path,:file=>file)
            list_of_files.each do |name|
              if fixture("file", "delete_file", {:file_name => name}) == "OK"
                ret_list_of_files << name
              end
            end
            return ret_list_of_files

          else

            if fixture("file", "delete_file", {:file_name => file}) == "OK"
              return File.basename(file)
            end
            return 

          end

        elsif arguments.include?(:dir)

          if fixture("file", "rm_dir", {:file_name => arguments[:dir]}) == "OK"
          	return arguments[:dir]
          end
          return

        else

          arguments.require_key :file, 'Argument $1 not found'
          arguments.require_key :dir, 'Argument $1 not found'

        end

      end

      # == description
		  # Copy files from sut \n
      #      
			# == arguments
			# arguments
      #  Hash
      #   description: Hash containing parameters to be used in file transfer
      #   example: Following symbols are supported
			#   [:file]
			#   [:from]
      #   [:to]
      #      
			# == returns
			# Array
      #  description: Copied files
      #  example: ["/dir/file.txt","/dir/file2.txt"]
      #
			# == exceptions
			# ArgumentErrors
      #  description: For missing / wrong argument types
      #
			# == info			
      #
      def copy_from_sut( arguments )

        arguments.check_type Hash, "wrong argument type $1 for #{ __method__.to_s } method (expected $2)"

        device_path=arguments[ :from ].gsub('\\','/') if arguments.include?( :from )

        if arguments[ :file ]!=nil
          file=arguments[ :file ].gsub('\\','/')
        else
          file='*.*'
        end

        if arguments[:to]!=nil
          tmp_path=arguments[:to].gsub('\\','/')
          if File::directory?(tmp_path)==false
            FileUtils.mkdir_p tmp_path
          end
        else
          tmp_path=Dir.getwd
        end

        if device_path!=nil
          list_of_files = list_files_from_sut(:from=>device_path,:file=>file)


          list_of_files.each do |name|
            end_index=(name.index File.basename(name))-1
            start_index=(name.index device_path)+device_path.length
            file_folder=name[start_index..end_index]
            receive_file_from_device(name,File.join("#{tmp_path}#{file_folder}",File.basename(name)))
          end
          return list_of_files
        else

          arguments.require_key :file, 'Argument $1 not found'

          receive_file_from_device(file,File.join(arguments[ :to ],File.basename(file)))

        end
      end

      # == description
      # Copy files to sut \n
      #      
			# == arguments
			# arguments
      #  Hash
      #   description: Hash containing parameters to be used in file transfer
			#   example: Following symbols are supported
			#   [:file]
			#   [:from]
      #   [:to]
      #      
      #
			# == returns
			# Array
      #  description: Copied files
      #  example: ["/dir/file.txt","/dir/file2.txt"]
      #
			# == exceptions
			# ArgumentErrors
      #  description: For missing / wrong argument types
      #
			# == info			
      #
      def copy_to_sut(arguments)

        arguments.check_type Hash, "wrong argument type $1 for #{ __method__.to_s } method (expected $2)"

        arguments.require_key :to, 'Argument $1 not found'

        begin
          local_dir = Dir.new( arguments[ :from ] ) if arguments.include?( :from )
        rescue Errno::ENOENT
          raise RuntimeError, "The source folder does not exist. Details:\n#{ $!.inspect }"
        end

        if arguments[ :file ]!=nil
          file=arguments[ :file ].gsub('\\','/')
        else file='*.*'
          file='*.*'
        end
        transfered_files=Array.new

        #ensure that the base dir exist
        fixture("file","mk_dir",{:file_name=>"#{arguments[ :to ]}"})
        
        if arguments.include?( :file )==false

          arguments.require_key :from, 'Argument $1 not found'

          local_dir.entries.each do | local_file_or_subdir |
            if !File.directory?( File.join( arguments[ :from ], local_file_or_subdir ) )
              send_file_to_device(
                      File.join( arguments[ :from ], local_file_or_subdir ),
                      File.join( arguments[ :to ], File.basename(local_file_or_subdir))
              )
              transfered_files << "#{arguments[ :to ]}/#{File.basename(local_file_or_subdir)}"
            elsif local_file_or_subdir != "." && local_file_or_subdir != ".."
              fixture("file","mk_dir",{:file_name=>"#{arguments[ :to ]}/#{local_file_or_subdir}"})
              transfered_files << copy_to_sut(:from=>"#{arguments[ :from ]}/#{local_file_or_subdir}",
                :to=>"#{arguments[ :to ]}/#{File.basename(local_file_or_subdir)}")
            end
          end
        elsif  arguments.include?( :file ) &&  arguments.include?( :from )
          local_dir.entries.each do | local_file_or_subdir |
            if !File.directory?( File.join( arguments[ :from ], local_file_or_subdir ) )
              send_file_to_device(
                      File.join( arguments[ :from ],local_file_or_subdir ),
                      File.join( arguments[ :to ], File.basename(local_file_or_subdir))
              ) if local_file_or_subdir.include?(file)
              transfered_files << "#{arguments[ :to ]}/#{File.basename(local_file_or_subdir)}"
            elsif local_file_or_subdir != "." && local_file_or_subdir != ".."
              fixture("file","mk_dir",{:file_name=>"#{arguments[ :to ]}/#{local_file_or_subdir}"})
              transfered_files << copy_to_sut(:file => arguments( :file ), :from=>"#{arguments[ :from ]}/#{local_file_or_subdir}",
                :to=>"#{arguments[ :to ]}/#{local_file_or_subdir}")
            end
          end
        else

          arguments.require_key :file, 'Argument $1 not found'

          fixture("file","mk_dir",{:file_name=>{:file_name=>arguments[ :to ]}})
          send_file_to_device(
                  file,
                  File.join(arguments[ :to ],File.basename(file))
          )
          transfered_files << "#{arguments[ :to ]}/#{File.basename(file)}"
        end
        return transfered_files
      end

      # == description
      # List files from sut \n
      #      
			# == arguments
			# arguments
      #  Hash
      #   description: Hash containing parameters to be used in file transfer
			#   example: Following symbols are supported
			#   [:file]
			#   [:from]
      #      
			# == returns
			# Array
      #  description: file list array
      #  example: ["/dir/file.txt","/dir/file2.txt"]
      #
			# == exceptions
			# ArgumentErrors
      #  description: For missing / wrong argument types
      #
			# == Info			
      #
      def list_files_from_sut( arguments )

        arguments.check_type Hash, "wrong argument type $1 for #{ __method__.to_s } method (expected $2)"

        arguments.require_key :from, 'Argument $1 not found'

        device_path=arguments[ :from ].gsub('\\','/')

        if arguments[ :file ]!=nil
          file=arguments[ :file ].gsub('\\','/')
        else file='*.*'
          file='*.*'
        end
        list_of_files = fixture("file", "list_files",
          {:file_name => file,
            :file_path => device_path}).split(';')
        return list_of_files

      end

      private

      def receive_file_from_device(device_file,local_file)
        if File::directory?(File.dirname(local_file))==false
          FileUtils.mkdir_p File.dirname(local_file)
        end
        new_file = File.new(local_file, 'wb')
        block_size = sut_parameters[:qt_file_transfer_block_size].to_i
        temp_size = block_size
        offset = 0
        while( temp_size == block_size )
          temp_data = Base64.decode64( fixture("file", "read_file_part", 
                                               {:file_name => device_file,
                                                :file_offset => offset,
                                                :data_lenght => block_size
                                                }) ) 
          temp_size = temp_data.size
          offset = offset + temp_size
          new_file.write(temp_data)
          print "\r Downloaded #{offset} bytes of #{device_file}"
        end
        new_file.close
        return local_file
      end

      def send_file_to_device(local_file, device_file)
          fixture("file", "delete_file", {:file_name => device_file})
          block_max_size = sut_parameters[:qt_file_transfer_block_size].to_i
          offset = 0
          file_size = File::Stat.new(local_file).size          
          file_to_be_sent = File.open(local_file,"rb")                    
          while(offset < file_size)
            block_size = file_size - offset
            if(block_size > block_max_size)
              block_size = block_max_size
            end
            buff = file_to_be_sent.readpartial(block_size)
            if(buff != nil)
              file_data = Base64.encode64(buff)
              fixture("file","write_file_append",
              { :file_name=>device_file,
                :file_data=>file_data,
                :file_offset=>offset,
                :data_lenght=>buff.size} )
              offset = offset + buff.size
            end
            print "\r Uploaded #{offset}/#{file_size} bytes of #{local_file}"
            
          end
          file_to_be_sent.close
      end

			# enable hooking for performance measurement & debug logging
			TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )


		end

	end

end
