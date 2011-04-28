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

require 'tmpdir'
require 'base64'

module MobyBehaviour

  module QT

    # == description
    # LocalisationDB specific behaviours
    #
    # == behaviour
    # QtLocalisationDB
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
    module LocalisationDB

      include MobyBehaviour::QT::Behaviour

      # == description
      # Creates a new localisation able for translation using the tdriver_parameters to locate the Localization DB. 
      # It uses the temporary folder to store temporary translation files.
      # The table structure will have the different languages as columns and the comun names will be set as the 
      # postfix language code from the source filenames for .qm and .ts files. For .loc files, the two-digit postfix
      # will be mapped to the same language codes as in .qm or .ts when possible forlowing the mapping table on 
      # symbian reference documentation. To see the full mapping used please check the localization.rb implementation 
      # file on testability-driver gem.
      #
      # == arguments
      # path
      #  String
      #   description: Path where the translation files to upload to the database are found
      #   example: "/usr/me/tdriver/localization_files"
      #
      # file
      #  String
      #   description: File names of the translation files to be uploaded.
      #	  example: "*.ts"
      #
      # database_file
      #  String
      #   description: If this is provided it will overwrite the value set in the parameter ':localisation_server_database_name'
      #   example: "mysqlitedb.sqlite"
      #
      # column_names_map
      #  Hash
      #   description: Hash with the language codes from the translation files as keys and the desired column names as values
      #   example: {"en" => "en_GB"}
      #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      def create_locale_db(path = "/", file = "*.qm", database_file = nil, column_names_map = {} )

		    db_type =  $parameters[ :localisation_db_type ]
		    host =  $parameters[ :localisation_server_ip ]
		    database_file = $parameters[ :localisation_server_database_name ] if database_file.nil?
		    username = $parameters[ :localisation_server_username ]
		    password = $parameters[ :localisation_server_password ]
		
		    db_connection = MobyUtil::DBConnection.new(  db_type, host, database_file, username, password )

		    table_name = sut_parameters[ :localisation_server_database_tablename, "" ]
                    
		    begin
			    tmp_path = $parameters[:tmp_folder] + "/locale_db_tmp"
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

        list_of_files = receive_files( path, file, tmp_path )

        list_of_files.each do |e_file|
          begin
            MobyUtil::Localisation.upload_translation_file( e_file, table_name, db_connection, column_names_map)	
          rescue Exception => e
            puts "Error while uploading #{e_file}."
            puts e.message
          end
        end

        nil

      end
	  
	  private 
	  
	    # == description
      # Receives files from SUT
	    #
      def receive_files( device_path, file, tmp_path )

        list_of_files = fixture( "file", "list_files", {:file_name => file, :file_path => device_path} ).split(';')
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
	    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # LocalisationDB

  end # QT

end # MobyBehaviour
