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

      # TODO: document me
      # overloads default MobyController::Abstraction#make_message
      def make_message
      
        command = @parameters[ :command ]
      
        case command
        
          when :version
          
            # query agent version from versionService
            Comms::MessageGenerator.generate( '<TasCommands service="versionService" />' )
        
        else
        
          # raise exception if command not implemented
          raise NotImplementedError, "command #{ command.inspect } not implemented in #{ self.class.name }"
        
        end
      
      end

    end # AgentCommand

  end  # QT    

end # MobyController
