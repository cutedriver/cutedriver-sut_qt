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

module MobyController

  module QT

    module Fixture 

      include MobyUtil::MessageComposer

      include MobyController::Abstraction

      # Creates service command message which will be sent to @sut_adapter by execute method
      # == params         
      # == returns
      # == raises
      def make_message

        # use local variable for less AST lookups
        sut_id = @sut_adapter.sut_id.to_sym

        plugin_name = @params[ :name ].to_s

        # retrieve plugin details from fixtures configuration
        plugin_params = $parameters[ sut_id ][ :fixtures ][ plugin_name.to_sym, nil ]

        # verify that plugin is configured
        plugin_params.not_nil "Fixture #{ plugin_name.inspect } not found for #{ sut_id.inspect }"

        # retrieve plugin name
        fixture_plugin = plugin_params.kind_of?( String ) ? plugin_params : plugin_params[ :plugin ] 

        Comms::MessageGenerator.generate(
          make_fixture_message(
            fixture_plugin, @params
          )
        )
            
      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # Fixture

  end # QT

end # MobyController
