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
    #
    # == behaviour
    # QtSettings
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
	module Settings

	  include MobyBehaviour::QT::Behaviour


      # == description
	  # Sets the given settings to the settings storage defined in the setting indentifiers.
	  # QSettings documentation will give more information on how the settigns are created 
	  # and accessed.
	  # 
      # == arguments
	  # identifiers
	  #  Hash
      #   description: Idenfifiers for the settings. See QSettings documentations for details on how
	  #                settings are accessed. You can use either direct file name or organization and 
	  #                application name way to access and edit the settings.
	  #                See [link="#identifier_params_table1"]file path access [/link] and 
	  #                [link="#identifier_params_table2"]registry access [/link] on how
	  #                specify the idenfitication details for the settings to be accessed.
	  #                
      #   example:     File name: {:fileName => '/etc/init/settings.ini', :format => 'Ini'}
	  #                Registry: {:organization => 'Tdriver', :application => 'qttasserver'}
	  #
	  # values
	  #  Hash
      #   description: Setting values to be edited (key and value)
      #   example: {:setting => 'value'}
	  #
      # == tables
      # identifier_params_table1
      #  title: Hash argument when using file path
      #  description: Valid values when using filepath to access settings.
      #  |Key|Description|Example|
      #  |:fileName|Settings file name or path to registry|:fileName => '/etc/init/settings.ini'|
      #  |:format|Settings storage format. Possible values: Ini, Native, Invalid|:format => 'Ini'|
	  #
      # identifier_params_table2
      #  title: Hash argument when using registry type access to settings
      #  description: Valid values when using registry type way to access settings.
      #  |Key|Description|Example|
      #  |:organization|Organization for the settings|:organization => 'MySoft'|
      #  |:application|Application using the settings|:application => 'MyApp'|
      #  |:format|Settings storage format. Possible values: ini, native, invalid. Defaults to Native if not set.|:format => 'native'|
      #  |:scope|Scope of the settings. User specific or system wide. Possible values: user, system. Defaults to user.|:scope => 'system'|
	  #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
      #    
	  def set_settings(identifiers, values)

		begin
		  raise ArgumentError.new("No values to set") unless values

		  params = generate_fixture_params(identifiers, values)
		  
		  fixture('setting', 'set', params)		  

		rescue Exception => e

		  $logger.behaviour "FAIL;Failed set settings \"#{identifiers.to_s}\", \"#{values.to_s}\".;set_settings;"
		  raise e

		end

		$logger.behaviour "PASS;Operation set settings executed successfully \"#{identifiers.to_s}\", \"#{values.to_s}\".;set_settings;"

		nil
	  end
  

      # == description
	  # Remove the settings corresponding to the given keys from the settings idenfitied by 
	  # the identifiers.
	  # 
      # == arguments
	  # identifiers
	  #  Hash
      #   description: Idenfifiers for the settings. See QSettings documentations for details on how
	  #                settings are accessed. You can use either direct file name or organization and 
	  #                application name way to access and edit the settings.
	  #                See [link="#identifier_params_table1"]file path access [/link] and 
	  #                [link="#identifier_params_table2"]registry access [/link] on how
	  #                specify the idenfitication details for the settings to be accessed.
	  #                
      #   example:     File name: {:fileName => '/etc/init/settings.ini', :format => 'Ini'}
	  #                Registry: {:organization => 'Tdriver', :application => 'qttasserver'}
	  #
	  # setting_keys
	  #  Array
      #   description: Array of settings keys which are to be removed.
      #   example: [setting1, setting2]
	  #
      # == returns
      # NilClass
      #   description: -
      #   example: -
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
      #    
	  def remove_settings(identifiers, setting_keys)
		begin
		  raise ArgumentError.new("No settings to remove") unless setting_keys
		  
		  params = generate_fixture_params(identifiers, nil)
		  setting_keys.each{|value| params[value.to_sym] = ''}
		  
		  fixture('setting', 'remove', params)		  

		rescue Exception => e

		  $logger.behaviour "FAIL;Failed remove settings \"#{identifiers.to_s}\", \"#{setting_keys.to_s}\".;remove_settings;"
		  raise e

		end

		$logger.behaviour "PASS;Operation remove settings executed successfully \"#{identifiers.to_s}\", \"#{setting_keys.to_s}\".;remove_settings;"

		nil
				  
	  end

      # == description
	  # Read the setting values corresponding to the given keys from the settings idenfitied by 
	  # the identifiers.
	  # 
      # == arguments
	  # identifiers
	  #  Hash
      #   description: Idenfifiers for the settings. See QSettings documentations for details on how
	  #                settings are accessed. You can use either direct file name or organization and 
	  #                application name way to access and edit the settings.
	  #                See [link="#identifier_params_table1"]file path access [/link] and 
	  #                [link="#identifier_params_table2"]registry access [/link] on how
	  #                specify the idenfitication details for the settings to be accessed.
	  #                
      #   example:     File name: {:fileName => '/etc/init/settings.ini', :format => 'Ini'}
	  #                Registry: {:organization => 'Tdriver', :application => 'qttasserver'}
	  #
	  # setting_keys
	  #  Array
      #   description: Array of settings keys which are to be removed.
      #   example: [setting1, setting2]
	  #
      # == returns
      # Hash
      #   description: Hash table with key value pairs for the settings read.
      #   example: {:setting => 'value'}
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
      #    
	  def read_settings(identifiers, setting_keys)
		hash = nil
		begin
		  raise ArgumentError.new("No settings to read") unless setting_keys

		  params = generate_fixture_params(identifiers, nil)
		  setting_keys.each{|value| params[value.to_sym] = ''}
		  
		  result_string =fixture('setting', 'read', params)
		  hash = JSON.parse(result_string)		  
		  
		rescue Exception => e

		  $logger.behaviour "FAIL;Failed read settings \"#{identifiers.to_s}\", \"#{setting_keys.to_s}\".;read_settings;"
		  raise e

		end

		$logger.behaviour "PASS;Operation read settings executed successfully \"#{identifiers.to_s}\", \"#{setting_keys.to_s}\".;read_settings;"

		hash

	  end

      # == description
	  # Read the all the setting values from the settings idenfitied by 
	  # the identifiers.
	  # 
      # == arguments
	  # identifiers
	  #  Hash
      #   description: Idenfifiers for the settings. See QSettings documentations for details on how
	  #                settings are accessed. You can use either direct file name or organization and 
	  #                application name way to access and edit the settings.
	  #                See [link="#identifier_params_table1"]file path access [/link] and 
	  #                [link="#identifier_params_table2"]registry access [/link] on how
	  #                specify the idenfitication details for the settings to be accessed.
	  #                
      #   example:     File name: {:fileName => '/etc/init/settings.ini', :format => 'Ini'}
	  #                Registry: {:organization => 'Tdriver', :application => 'qttasserver'}
	  #
	  #
      # == returns
      # Hash
      #   description: Hash table with key value pairs for the settings read.
      #   example: {:setting => 'value'}
      #
      # == exceptions
      # ArgumentError
      #  description:  In case the given parameters are not valid.
      #    
	  def read_all_settings(identifiers)
		hash = nil
		begin

		  params = generate_fixture_params(identifiers, nil)
		  result_string =fixture('setting', 'readAll', params)
		  hash = JSON.parse(result_string)		  
		  
		rescue Exception => e

		  $logger.behaviour "FAIL;Failed read all settings \"#{identifiers.to_s}\".;read_all_settings;"
		  raise e

		end

		$logger.behaviour "PASS;Operation read all settings executed successfully \"#{identifiers.to_s}\".;read_all_settings;"

		hash

	  end

	  private 
	  
	  def generate_fixture_params(identifiers, params)

		raise ArgumentError.new("No enough information to access settings. Define filename or organization") unless identifiers[:fileName] or identifiers[:organization]		
		raise ArgumentError.new("Cannot define both fileName and organization.") if identifiers[:fileName] and identifiers[:organization]
		
		fixture_params = Hash.new
		fixture_params[:settingFileName] = identifiers[:fileName] if identifiers[:fileName]
		fixture_params[:settingOrganization] = identifiers[:organization] if identifiers[:organization]

		fixture_params[:settingApplication] = identifiers[:application] if identifiers[:application]
		fixture_params[:settingFormat] = identifiers[:format] if identifiers[:format]
		fixture_params[:settingScope] = identifiers[:scope] if identifiers[:scope]
		fixture_params.merge!(params) if params
		fixture_params
	  end

	  # enable hooking for performance measurement & debug logging
	  TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )


	end # Settings

  end

end # MobyBase
