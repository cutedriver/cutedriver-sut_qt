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

## DESCRIPTION
# This script will take .qm or .ts files from SUT
# to convert those into SQL tables to a server following 
# the TDriver table structure for locale data

## REQUIREMENTS
# mysql gem installed on the system
# QT's lconvert on the path

#require 'tdriver'
require 'nokogiri'
require 'tmpdir'
require 'base64'

module MobyBehaviour

  module QT

    module SUT

      include MobyBehaviour::QT::Behaviour

      # rebuilds localisation db
      # ==raises
      def create_locale_db(path = "/", file = "*.qm", database_file = nil, column_names_map = {} )

        ## OPTIONS
        @options = {}
        @options[:table_name] = ""
        @options[:host] = ""
        @options[:user] = ""
        @options[:passwd] = ""
        @options[:db] = ""
        @options[:dbstyle] = ""
        @options[:sqlitedb] = ""

        @options[:dbstyle] = MobyUtil::Parameter[ :localisation_db_type ]

        @options[:table_name] = MobyUtil::Parameter[ :sut_qt ][ :localisation_server_database_tablename ]
                
        @options[:host] = MobyUtil::Parameter[ :localisation_server_ip ]
        @options[:user] = MobyUtil::Parameter[ :localisation_server_username ]
        @options[:passwd] = MobyUtil::Parameter[ :localisation_server_password ]
                
        @options[:sqlitedb] = MobyUtil::Parameter[ :localisation_server_database_name ]

        @options[:db] = "tdriver_locale"

        if(database_file != nil)
          @options[:sqlitedb] = database_file;
        end
                
				begin
					tmp_path = MobyUtil::Parameter[:tmp_folder] + "/locale_db_tmp"
				rescue MobyUtil::ParameterNotFoundError
					tmp_path = Dir.tmpdir + "/locale_db_tmp"
				end
        if (File.directory? tmp_path)
          FileUtils.rm_rf(tmp_path)
        end
        if (File.directory? tmp_path)
        else
          FileUtils.mkdir(tmp_path)
        end

        list_of_files = receive_files(path, file, tmp_path)
        list_of_files.each do |e_file|
          # Check File and convert to TS File if needed
		  tsFile = MobyUtil::Localisation.convert_to_ts(e_file)
          next if tsFile == nil
                    
          # Collect data for INSERT query from TS File
          language, data = MobyUtil::Localisation.parse_ts_file(tsFile, column_names_map)
          next if language == nil or data == ""

          # Upload language data to DB for current language file
          MobyUtil::Localisation.upload_ts_data(e_file, language, data, @options[:table_name])
        end

        nil
      end

	  
	  private 
	  	  
      #receives files from SUT
      def receive_files(device_path, file, tmp_path)
        list_of_files = fixture("file", "list_files",
          {:file_name => file,
            :file_path => device_path}).split(';')


        new_list_of_files = Array.new
        list_of_files.each do |name|
          new_list_of_files.push( tmp_path + "/" + File.basename(name) )
          file = File.open(tmp_path + "/" + File.basename(name), 'w')
          file << Base64.decode64( fixture("file", "read_file", {:file_name => name}) )
          file.close
        end
        return new_list_of_files
      end

	# enable hooking for performance measurement & debug logging
	MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

    end

  end

end
