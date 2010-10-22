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

	module TreeWidgetItemColumn

	  include MobyBehaviour::QT::Behaviour

	  # Sets the check state of the item in a treewidget
	  # == params
	  # == returns  
	  # == raises
	  def check_state(new_state)

		ret = nil

		begin    

		  raise ArgumentError.new( "new_state must be an integer. Check qt docs for allowed values (Qt::CheckState." ) unless new_state.kind_of?(Integer) 
		  
		  command = MobyCommand::WidgetCommand.new
		  command.object_id(self.attribute('parentWidget'))
		  command.application_id(get_application_id)    
		  command.object_type(:Standard)                          
		  command.command_name('CheckState')    
		  params = {:state => new_state, :column => self.attribute('column'), :item => self.attribute('parentItem')}      

          command.set_event_type(MobyUtil::Parameter[ @sut.id ][ :event_type, "0" ])

		  command.command_params(params)
		  @sut.execute_command(command)

		rescue Exception => e      

		  MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed select"#{identity};drag;"
		  Kernel::raise e        

		end      

		MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation select executed successfully"#{identity};drag;"
		ret

	  end

	  # enable hooking for performance measurement & debug logging
	  MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )
	end

  end
end
