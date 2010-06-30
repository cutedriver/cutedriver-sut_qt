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

	class Fixture < MobyCommand::CommandData

		attr_accessor :application_id, :name, :command, :params, :transitions, :object_id, :object_type, :asynchronous
	    
		def initialize(application_id = "", object_id ="" , object_type = "", name = nil, command_name = nil, parameter_hash = {}, async = false)

			@application_id = application_id

			@name = name
			@command = command_name
			@params = parameter_hash

			@transitions = false
			@object_id = object_id
			@object_type = object_type
			@asynchronous = async

		end
		    
	end # Fixture

end # MobyCommand
