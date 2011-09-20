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
    # TreeWidgetItemColumn specific behaviours
    #
    # == behaviour
    # QtTreeWidgetItemColumn
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
    # TreeWidgetItemColumn
    #
	  module TreeWidgetItemColumn

	    include MobyBehaviour::QT::Behaviour

      # == description
	    # Sets the check state of the item in QTreeWidgetItemColumn.\n
	    #
	    # == arguments
	    # new_state
	    #  Integer
	    #   description: State of checkable item, see supported values in [link="#check_state_enums"]table[/link] below
	    #   example: 0
	    #
	    # == returns
	    # NilClass
	    #  description: -
	    #  example: -
	    #
      # == tables
      # check_state_enums
      #  title: Supported item states (Qt 4.7)
      #  description: See Qt documentation for allowed values to QT::CheckState
      #  |Enum|Value|Description|
      #  |Qt::Unchecked|0|The item is unchecked.|
      #  |Qt::PartiallyChecked|1|The item is partially checked.|
      #  |Qt::Checked|2|The item is checked.|
      #
	    # == returns
	    def check_state( new_state )

		    ret = nil

		    begin    

		      raise ArgumentError.new( "new_state must be an integer. Check qt docs for allowed values (Qt::CheckState." ) unless new_state.kind_of?(Integer) 
		      
		      command = MobyCommand::WidgetCommand.new

		      command.set_object_id(attribute('parentWidget'))

		      command.application_id(get_application_id)    
		      command.object_type(:Standard)                          
		      command.command_name('CheckState')
    
		      command.set_event_type( sut_parameters[ :event_type, "0" ] )

		      params = {:state => new_state, :column => attribute('column'), :item => attribute('parentItem')}      

          command.set_event_type( sut_parameters[ :event_type, "0" ] )

		      command.command_params(params)
		      @sut.execute_command(command)

		    rescue Exception => e      

		      $logger.behaviour "FAIL;Failed select"#{identity};drag;"
		      raise e        

		    end      

		    $logger.behaviour "PASS;Operation select executed successfully"#{identity};drag;"
		    ret

	    end

	    # enable hooking for performance measurement & debug logging
	    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
	  end

  end
end
