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

	class ConfigureCommand < MobyCommand::CommandData

		attr_accessor :name, :params, :value, :application_id
	    
		def initialize(name = nil, parameter_hash = {}, value = "")

		  @name = name
		  @params = parameter_hash
		  @value = value
		  @application_id = ""
		end
		    
	end # ConfigureCommand

end # MobyCommand
