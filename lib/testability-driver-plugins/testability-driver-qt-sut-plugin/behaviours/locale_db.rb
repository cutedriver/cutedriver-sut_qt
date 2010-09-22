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
          tsFile = prepare_file_as_ts(e_file)
          next if tsFile == nil
                    
          # Collect data for INSERT query from TS File
          #language, data = collectDataFromTS(tsFile)
          language, data = nokogiri_ts_file(tsFile, column_names_map)
          next if language == nil or data == ""

          # Upload language data to DB for current language file
          upload_data(e_file, language, data)
        end

        nil
      end

      private

      # Check File and convert to TS if needed
      def prepare_file_as_ts(file)
        #puts "-> Processing file '" + file + "'"
        if !File.exists?(file)
          puts "[WARNING] File '" + file + "' not found. Skiping."
          file = nil
        elsif  (nil == file.match(/.*\.ts/) and nil == file.match(/.*\.qm/) )
          puts "[WARNING] Unknown file extension. Skiping. \n\n" + file
          file = nil
        elsif ( match = file.match(/(.*)\.qm/) )
          #puts "Converting '" + match[0] + "' to .ts ..."
          if(! system "lconvert -o " + match[1] + ".ts " + file )
            puts "[ERROR] lconvert can't convert .qm file to .ts. Skiping. \n\n" + match[0]
          end
          file = match[1] + ".ts"
        end
        file
      end

      def nokogiri_ts_file(file, column_names_map = {} )
        # Read TS file
        open_file = File.new( file )
        doc = Nokogiri.XML( open_file )
        language = doc.xpath('.//TS').attribute("language")
		######## IF filename-to-columnname mapping is provided provided 
		if (!column_names_map.empty?)
		
			file_language_code = file.match(/.*[_]([a-zA-Z_]{2})\.ts/) 		# filename_xx.ts 
			file_language_code_long = file.match(/.*[_]([a-zA-Z_]{5})\.ts/) # filename_xx_YY.ts 
			
			# .ts file has no language code on the name just use whatever has been found in the xml language attribute for <TS>
			if file_language_code.nil? and file_language_code_long.nil?	
				
			# use short language code to check for column mapping (i.e. file_en.ts, language_code["en"] => column_name["en GB"])
			elsif file_language_code_long.nil?
				language_code = file_language_code[1]
				language = column_names_map[ language_code ] if column_names_map.key?(language_code)
			
			# use short language code to check for column mapping (i.e. file_en.ts, language_code["en_US"] => column_name["en US"])
			else
				language_code = file_language_code_long[1]
				language = column_names_map[ language_code ] if column_names_map.key?(language_code)
			
			end
		end
	  ###########
        if (language == nil)
          puts "[WARNING] The input file is missing the language attribute on it's <TS> element. Skiping. \n\n"
          return nil, nil
        end
        #puts "Language: " + language
        # Collect data for INSERT query
        data = []
        doc.xpath('.//message').each do |node|
		  begin
			nodeId = ""
			nodeTranslation = ""
			nodePlurality = ""
			nodeLengthVar = ""
			
			# set nodeId
			#raise Exception if node.xpath('@id').inner_text() == ""
			if node.xpath('@id').inner_text() != ""
				nodeId = node.xpath('@id').inner_text()
			else
				nodeId = node.xpath('.//source').inner_text()
			end
			
			# Parse Numerus(LengthVar), or Numerus or LengthVar or translation direclty
			if ! node.xpath('.//translation/numerusform').empty?
				# puts ">>> Numerusform"
				node.xpath('.//translation/numerusform').each do |numerus|
					nodePlurality = numerus.xpath('@plurality').inner_text()
					if ! numerus.xpath('.//lengthvariant').empty?
						# puts "  >>> Lengthvar"
						numerus.xpath('.//lengthvariant').each do |lenghtvar|
							nodeLengthVar = lenghtvar.xpath('@priority').inner_text()
							nodeTranslation = lenghtvar.inner_text()
							data << [  nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
						end
					else
						nodeTranslation = numerus.inner_text()
						data << [  nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
					end
				end			
			elsif ! node.xpath('.//translation/lengthvariant').empty?
				# puts ">>> Lengthvar"
				node.xpath('.//translation/lengthvariant').each do |lenghtvar|
					nodeLengthVar = lenghtvar.xpath('@priority').inner_text()
					nodeTranslation = lenghtvar.inner_text()
					data << [  nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
				end
			else
				# puts ">>> Translation"
				nodeTranslation = node.xpath('.//translation').inner_text()
				data << [  nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
			end
			
		  rescue Exception # ignores bad elements or elements with empty translations for now
		  end
        end
        open_file.close
        return language, data
      end
	  
	  # Parses filenames and strips the extension and language tags of the name 
	  def parseFName(file)
		fname = file.split('/').last
		#(wordlist matching)
		words = ["ar", "bg", "ca", "cs", "da", "de", "el", "en", "english-gb", "(apac)", "(apaccn)", "(apachk)", "(apactw)", "japanese", "thai", "us", "es", "419", "et", "eu", "fa", "fi", "fr", "gl", "he", "hi", "hr", "hu", "id", "is", "it", "ja", "ko", "lt", "lv", "mr", "ms", "nb", "nl", "pl", "pt", "br", "ro", "ru", "sk", "sl", "sr", "sv", "th", "tl", "tr", "uk", "ur", "us", "vi", "zh", "hk", "tw", "no"]
		match = fname.scan(/_([a-zA-Z1-9\-\(\)]*)/)
		if match
			match.each do |m|
				fname.gsub!("_#{m[0]}"){|s| ""} if words.include?( m[0].downcase )
			end
		end
		fname.gsub!(".ts"){|s| ""}
	  end

      # Upload language data to DB
      def upload_data (file, language, data)

        if @dbh == nil
          case @options[:dbstyle]
          when "mysql"
            require 'mysql'
          when "sqlite"
            require 'sqlite3'
          end
        end

        # Connect to DB
        if @dbh == nil
          case @options[:dbstyle]
          when "mysql"
            @dbh = Mysql.connect(host = @options[:host], user = @options[:user], passwd = @options[:passwd], db = @options[:db], port=nil, sock=nil, flag=nil)
            @dbh.query("SET NAMES utf8")
          when "sqlite"
            begin
              @dbh = SQLite3::Database.new( @options[:sqlitedb] )
            rescue SQLite3::NotADatabaseException
              #puts "'" + @options[:sqlitedb] + "' is not an SQlite database file."
              return  # Just finish
            end
          end
        end

        # Create table if doesn't exist (language collumns to be created as needed)
        #puts "Preparing table '" + @options[:table_name] + "' in the database."
        case @options[:dbstyle]
        when "mysql"
          sth = @dbh.prepare(
            "CREATE TABLE IF NOT EXISTS " + @options[:table_name] + " (
                    `ID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
		    `FNAME` VARCHAR(150) NOT NULL COLLATE latin1_general_ci,
		    `LNAME` VARCHAR(150) NOT NULL COLLATE latin1_general_ci,
		    `PLURALITY` VARCHAR(50) COLLATE latin1_general_ci,
		    `LENGTHVAR` INT(10),
		    PRIMARY KEY (`ID`),
		    UNIQUE INDEX `FileLogicNameIndex` (`FNAME`,`LNAME`, `PLURALITY`, `LENGTHVAR`),
		    INDEX `LNameIndex` (`LNAME`)
		    ) COLLATE=utf8_general_ci;"
          )
          sth.execute
        when "sqlite"
          @dbh.execute(
            "CREATE TABLE IF NOT EXISTS " + @options[:table_name] + " (
                    `ID` INTEGER PRIMARY KEY AUTOINCREMENT,
                    `FNAME` VARCHAR(150) NOT NULL,
                    `LNAME` VARCHAR(150) NOT NULL
					`PLURALITY` VARCHAR(50),
					`LENGTHVAR` INT(10)
                );"
          )
          query = "CREATE UNIQUE INDEX IF NOT EXISTS 'FileLogicNameIndex' ON " + @options[:table_name] + " (`FNAME`,`LNAME`, `PLURALITY`, `LENGTHVAR`);"
		  dbh.execute(query)
		  query = "CREATE INDEX IF NOT EXISTS 'FileLogicIndex' ON " + @options[:table_name] + " (`LNAME`);"
		  dbh.execute(query)	
        end


        # Add new column for new language if needed
        #puts "Adding translations for " + language + " to the database."
        case @options[:dbstyle]
        when "mysql"
          begin
            sth = @dbh.prepare("ALTER TABLE `" + @options[:table_name] + "` ADD  `" + language + "` VARCHAR(350) NULL DEFAULT NULL;")
            sth.execute
          rescue Mysql::Error # catch if language column already exists
          end
        when "sqlite"
          begin
            @dbh.execute("ALTER TABLE `" + @options[:table_name] + "` ADD  `" + language + "` TEXT;")
          rescue SQLite3::SQLException # catch if language column already exists
          end
        end


        # Format and INSERT data
	fname = parseFName(file)
        case @options[:dbstyle]
        when "mysql"
          begin
            # Formatting (seems like there is no length limit for the insert string)
            insert_values = ""
	    data.each do |source, translation, plurality, lengthvar|
              # Escape ` and ' and "  and other restricted characters in SQL (prevent SQL injections
              source = source.gsub(/([\'\"\`\;\&])/){|s|  "\\" + s}
              translation = (translation != nil) ? translation.gsub(/([\'\"\`\;\&])/){|s|  "\\" + s} : ""
              insert_values += "('" + fname + "', '" + source + "', '" + translation + "', '" + plurality + "', '" + lengthvar + "'), "
            end
            insert_values[-2] = ' ' unless insert_values == "" # replace last ',' with ';'

            # INSERT Query
            sth = @dbh.prepare( "INSERT INTO `" + @options[:table_name] + "` (FNAME, LNAME, `" + language + "`, `PLURALITY`, `LENGTHVAR`) VALUES " + insert_values +
                "ON DUPLICATE KEY UPDATE fname = VALUES(fname), lname = VALUES(lname), `" + language + "` = VALUES(`" + language + "`) ;")
            n = sth.execute
            #puts ">>> " + n.affected_rows.to_s + " affected rows"

          rescue Exception => e
            puts e.inspect
            puts e.backtrace.join("\n")
          end

        when "sqlite"
          begin
            # Formatting (limit on the length of the Insert String! So multiple Insets
            counter = 0
            cumulated = 0
            union_all = ""
            data.each do |source, translation|
              counter += 1
              cumulated += 1
              # we MAYBE  fucked if the texts have ";" or "`" or """ but for now only "'" seems to be problematic
              source = source.strip.gsub(/([\'])/){|s|  s + s}
              translation = (translation != nil ) ? translation.strip.gsub(/([\'])/){|s|  s + s} : ""
              union_all += " SELECT '" + fname + "' ,'" + source + "','" + translation + "', '" + plurality + "', '" + lengthvar + "'  UNION ALL\n"
              # INSERT Query if whe have collected enough or the last remaining (500 limit for now)
              if (counter >= 500 or cumulated == data.length)
                union_all[-11..-1] = '' # strip last UNION ALL
                @dbh.execute("INSERT OR REPLACE INTO `" + @options[:table_name] + "` (FNAME, LNAME, `" + language + "`, `PLURALITY`, `LENGTHVAR`) " + union_all)
                puts ">>> " + @dbh.changes().to_s + " affected rows"
                counter = 0
                union_all = ""
              end
            end
          rescue Exception => e
            puts e.inspect
            puts e.backtrace.join("\n")
          end
        end
      end

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
