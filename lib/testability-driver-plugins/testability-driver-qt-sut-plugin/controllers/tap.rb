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

    module Tap 

      include MobyController::Abstraction

      # Creates service command message which will be sent to @sut_adapter by execute method
      # == params         
      # == returns
      # == raises
      def make_message

        Comms::MessageGenerator.generate(
          Nokogiri::XML::Builder.new{
            TasCommands( :service => "uiCommand" ) {
              Target( :TasId => 1, :type => "Application" ) {
                Command( 
                  :name => "TapScreen", 
                  :x => get_x, 
                  :y => get_y, 
                  :button => 1, 
                  :count => 1, 
                  :mouseMove => true, 
                  :useCoordinates => true, 
                  :time_to_hold => get_hold 
                )
              }
            }
          }.to_xml
        )

      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # Tap

  end # QT

end # MobyController
