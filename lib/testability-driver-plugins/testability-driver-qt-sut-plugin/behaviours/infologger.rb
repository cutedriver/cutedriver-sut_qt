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

	module InfoLoggerBehaviour

	  include MobyBehaviour::QT::Behaviour

	  #params: hash of needed paramters [:interval => 1, filePath => 'c:\Data']
	  def log_cpu(params)
		params[:action] = 'start'
		execute_info('cpu', params)
	  end

	  def stop_cpu_log(params={})
		params[:action] = 'stop' 
		execute_info('cpu', params)
	  end

	  def log_mem(params)
		params[:action] = 'start'
		execute_info('mem', params)
	  end

	  def stop_mem_log(params={})
		params[:action] = 'stop' 
		execute_info('mem', params)
	  end

	  def log_gpu_mem(params)
		params[:action] = 'start'
		execute_info('gpu', params)
	  end

	  def stop_gpu_log(params={})
		params[:action] = 'stop' 
		execute_info('gpu', params)
	  end

	  def load_cpu_log(params={})
		params[:action] = 'load' 
		execute_info('cpu', params)
	  end

	  def load_mem_log(params={})
		params[:action] = 'load' 
		execute_info('mem', params)
	  end

	  def load_gpu_log(params={})
		params[:action] = 'load' 
		execute_info('gpu', params)
	  end

	  private

	  def execute_info(service, params)
		begin

		  validate_params(params)

		  time = params[:interval].to_f
		  interval = time*1000
		  params[:interval] = interval.to_i

		  command = MobyCommand::InfoLoggerCommand.new(service, params )

		  ret = nil
		  if self.class == MobyBase::SUT
			ret = execute_command( command ) 
		  else
			command.application_id = get_application_id
			ret = @sut.execute_command( command )
		  end

		rescue Exception => e      
		  MobyUtil::Logger.instance.log "behaviour","FAIL;Failed infologger \"#{params.to_s}\".;#{service};"
		  Kernel::raise e        
		end      
		MobyUtil::Logger.instance.log "behaviour","PASS;Operation infologger succeeded with params \"#{params.to_s}\".;#{service};"
		ret	
	  end

	  def validate_params(params)
		#type
		raise ArgumentError.new("Parameters must be a hash (e.g. {:filePath => 'C:\Data\',:interval => 1 }") unless params.kind_of?(Hash)
		if params[:action] == 'start'
		  #speed 
		  raise ArgumentError.new("Log file path must be defined (e.g. :filePath => 'C:\Data\')") unless params[:filePath]
		  #distance
		  raise ArgumentError.new("Interval 1 must be an number (e.g. :interval => 1") unless params[:interval].kind_of?(Numeric)
		end
	  end

	# enable hooking for performance measurement & debug logging
	MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


	end
  end
end
