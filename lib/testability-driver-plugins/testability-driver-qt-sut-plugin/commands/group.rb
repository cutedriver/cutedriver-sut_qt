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

module MobyCommand

  class Group < MobyCommand::CommandData

	  attr_reader :interval, :application, :block, :multitouch

	  # Constructor to Group
	  # == params
	  # interval: interval between commands
	  # application: target application
	  # block: block of commands to group
	  def initialize( interval, application, block )    
	    @interval = interval
	    @application = application
	    @block = block
	    @multitouch = false
	  end

	  def set_multitouch(multitouch = true)
	    @multitouch = multitouch
	  end

  end # Group

end # MobyCommand
