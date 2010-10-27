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
    #  sut_qt
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
    # Sut
    #
		module FileTransfer

			include MobyBehaviour::QT::Behaviour

      # == description
      # Delete files from sut
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
			# deleted file array or deleted directory
      #
			# == exceptions
			# ArgumentErrors
      #  description: For missing / wrong argument types
      #
			# == info
			# @sut.delete_from_sut(:from => 'E:\', :file => '*.log') # delete all files with log file extension from E: drive
      # @sut.delete_from_sut(:file => 'E:\logs\test.log') # delete E:\logs\test.log file from device
      # @sut.delete_from_sut(:dir => 'E:\logs') # delete E:\logs directory from device
      #
      def delete_from_sut(arguments)
        MobyBase::Error.raise( :WrongArgumentType, arguments.class, "hash" ) unless arguments.kind_of?( Hash )

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

          Kernel::raise ArgumentError.new( "Argument :file not found") unless arguments.include?( :file )
          Kernel::raise ArgumentError.new( "Argument :dir not found") unless arguments.include?( :dir )

        end

      end

      # == description
		  # Copy files from sut
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
      # [code]
      # @sut.copy_from_sut(:from => 'E:\', :file => '*.log', :to => 'C:\temp\') # copy all files with log file extension from E: drive
      # @sut.copy_from_sut(:file => 'E:\logs\test.log') # copy E:\logs\test.log file from device
      # [/code]
			# == returns
			# copied files in array
      #
			# == exceptions
			# ArgumentErrors
      #  description: For missing / wrong argument types
      #
			# == info			
      #
      def copy_from_sut(arguments)
        MobyBase::Error.raise( :WrongArgumentType, arguments.class, "hash" ) unless arguments.kind_of?( Hash )

        device_path=arguments[ :from ].gsub('\\','/') if arguments.include?( :from )

        if arguments[ :file ]!=nil
          file=arguments[ :file ].gsub('\\','/')
        else file='*.*'
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
            write_file("#{tmp_path}#{file_folder}",name)
          end
          return list_of_files
        else
          Kernel::raise ArgumentError.new( "Argument :file not found") unless arguments.include?( :file )
          new_file=write_file(tmp_path,file)
          return new_file
        end
      end

      # == description
      # Copy files to sut
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
      # [code]
      # @sut.copy_to_sut(:from => 'C:\temp', :to => 'E:\logs\') # copy all files to E:\logs folder in sut
      # @sut.copy_to_sut(:file => 'C:\logs\test.log', :to => 'E:\temp\') # copy C:\logs\test.log file to E:\temp folder in sut
      # [/code]
      #
			# == returns
			# copied files in array
      #
			# == exceptions
			# ArgumentErrors
      #  description: For missing / wrong argument types
      #
			# == info			
      #
      def copy_to_sut(arguments)
        MobyBase::Error.raise( :WrongArgumentType, arguments.class, "hash" ) unless arguments.kind_of?( Hash )
        Kernel::raise ArgumentError.new( "Argument :to not found") unless arguments.include?( :to )

        begin
          local_dir = Dir.new( arguments[ :from ] ) if arguments.include?( :from )
        rescue Errno::ENOENT => ee
          Kernel::raise RuntimeError.new( "The source folder does not exist. Details:\n" + ee.inspect )
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
          Kernel::raise ArgumentError.new( "Argument :from not found") unless arguments.include?( :from )
          local_dir.entries.each do | local_file_or_subdir |
            if !File.directory?( File.join( arguments[ :from ], local_file_or_subdir ) )
              fixture("file","write_file",
                {:file_name=>arguments[ :to ]+'/'+File.basename(local_file_or_subdir),
                  :file_data=>Base64.encode64(read_file(File.join( arguments[ :from ],
                        local_file_or_subdir )))})
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
              fixture("file","write_file",
                {:file_name=>arguments[ :to ]+'/'+File.basename(local_file_or_subdir),
                  :file_data=>Base64.encode64(read_file(File.join( arguments[ :from ],
                        local_file_or_subdir )))}) if local_file_or_subdir.include?(file)
              transfered_files << "#{arguments[ :to ]}/#{File.basename(local_file_or_subdir)}"
            elsif local_file_or_subdir != "." && local_file_or_subdir != ".."
              fixture("file","mk_dir",{:file_name=>"#{arguments[ :to ]}/#{local_file_or_subdir}"})
              transfered_files << copy_to_sut(:file => arguments( :file ), :from=>"#{arguments[ :from ]}/#{local_file_or_subdir}",
                :to=>"#{arguments[ :to ]}/#{local_file_or_subdir}")
            end
          end
        else
          Kernel::raise ArgumentError.new( "Argument :file not found") unless arguments.include?( :file )
          fixture("file","mk_dir",{:file_name=>{:file_name=>arguments[ :to ]}})
          fixture("file","write_file",
            {:file_name=>arguments[ :to ]+'/'+File.basename(file),
              :file_data=>Base64.encode64(read_file(file))})
          transfered_files << "#{arguments[ :to ]}/#{File.basename(file)}"
        end
        return transfered_files
      end

      # == description
      # List files from sut
      #
			# == arguments
			# arguments
      #  Hash
      #   description: Hash containing parameters to be used in file transfer
			#   example: Following symbols are supported
			#   [:file]
			#   [:from]
      #
      # [code]
      # @sut.list_files_from_sut(:from => 'C:\temp', :file => '*.log') # list all files with log file extension
      # @sut.list_files_from_sut(:from = 'C:\') # list alls files from C: drive
      # @sut.list_files_from_sut(:from = 'C:\temp') # list all files from c:\temp
      # [/code]
			# == returns
			# file list array
      #
			# == exceptions
			# ArgumentErrors
      #  description: For missing / wrong argument types
      #
			# == Info			
      #
      def list_files_from_sut(arguments)
        MobyBase::Error.raise( :WrongArgumentType, arguments.class, "hash" ) unless arguments.kind_of?( Hash )
        Kernel::raise ArgumentError.new( "Argument :from not found") unless arguments.include?( :from )
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

      def write_file(target_folder,source_file)
        if File::directory?(target_folder)==false
          FileUtils.mkdir_p target_folder
        end
        new_file = File.open(target_folder + "/" + File.basename(source_file), 'w')
        new_file << Base64.decode64( fixture("file", "read_file", {:file_name => source_file}) )
        new_file.close
        return target_folder + "/" + File.basename(source_file)
      end

      def read_file(source_file)
        file_data=''
        if File.file?(source_file)
          open_file = File.open(source_file, 'r')
          open_file.each_line do |line|
            file_data += line
          end
        end
        return file_data.to_s
      end


				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


		end

	end

end
