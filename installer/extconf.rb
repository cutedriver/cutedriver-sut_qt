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



require 'rubygems'

begin

	require 'tdriver/util/loader'

rescue LoadError => exception

	raise LoadError, 'SUT plugin requires TDriver'

end

MobyUtil::GemHelper.install( MobyUtil::FileHelper.tdriver_home ){ | tdriver_home_folder |

	[ 

		# default parameters & sut configuration
		[ "../xml/defaults/*.xml",  "defaults/", true ],

		# parameters
		[ '../xml/behaviour/*.xml', "behaviours/", true ],
		[ '../xml/behaviour/*.xml', "default/behaviours/", true ],

		# templates
		[ "../xml/template/*.xml",  "templates/", true ],
		[ "../xml/template/*.xml",  "default/templates/", true ],

		# behaviours
		[ "../xml/keymap/*.xml",  "keymaps/", true ],
		[ "../xml/keymap/*.xml",  "default/keymaps/", true ]

		].each { | task |

			source, destination, overwrite = task

			MobyUtil::FileHelper.copy_file( source, "#{ tdriver_home_folder }/#{ destination }", false, overwrite, true )

	}

}

