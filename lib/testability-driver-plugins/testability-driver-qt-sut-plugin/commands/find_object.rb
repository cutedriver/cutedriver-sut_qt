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

  class FindObjectCommand < MobyCommand::CommandData
    
    # Constructor
    # == params
    # btn_id:: (optional) String, id for the button perform this command on
    # command_type:: (optional) Symbol, defines the command to perform on the button
    # == returns
    # MobyCommand::FindObjectCommand:: New CommandData object
    # == raises
    # ArgumentError:: When the supplied command_type is invalid.
    def initialize( sut, app_details = nil, params = nil, checksum = nil )

      @_params = params

      @_app_details = app_details

      @_sut = sut

      @_checksum = checksum

    end

    # TODO: document me
    def application_details

      @_app_details

    end

    # TODO: document me
    def search_parameters

      @_params

    end

    # TODO: document me
    def checksum

      @_checksum

    end

  end # FindObjectCommand

end # MobyCommand
