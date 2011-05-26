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
  
    module AgentCommand
      
      include MobyController::Abstraction

      include MobyUtil::MessageComposer

      def make_message
      
        case @parameters[:command]
        
          when :version
          
            MobyController::QT::Comms::MessageGenerator.generate( '<TasCommands service="versionService" />' )
        
        else
        
          raise NotImplementedError, "command #{ @parameters[:command].inspect } not implemented in #{ self.class.name }"
        
        end
      
      end

    end # AgentCommand

  end  # QT    

end # MobyController
