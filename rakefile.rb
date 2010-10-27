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
require 'rake/gempackagetask'

require File.expand_path( File.join( File.dirname( __FILE__ ), 'env' ) )

@__release_mode = ENV['rel_mode']
@__release_mode = 'minor' if @__release_mode == nil
  
# version information
def read_version
	version = "0"
	File.open(Dir.getwd << '/debian/changelog') do |file|
		
		line = file.gets
		arr = line.split(')')
		arr = arr[0].split('(')
		arr = arr[1].split('-')
		version = arr[0]
	end
	
	if( @__release_mode == 'release' )
		return version
	elsif( @__release_mode == 'cruise' )
		return version + "." + Time.now.strftime("pre%Y%m%d")
	else
		return version + "." + Time.now.strftime("%Y%m%d%H%M%S")   
	end
end

puts "version " << ( @__revision = read_version )

@__gem_version = @__revision

spec = Gem::Specification.new{ | s |

  gem_version 	=   PLUGIN_VERSION
  s.platform      =   Gem::Platform::RUBY
  s.name          =   GEM_NAME
  s.version       =   "#{ @__gem_version }"
  s.author        =   "TDriver team"
  s.email         =   "testabilitydriver@nokia.com"
  s.homepage      =   "http://gitorious.org/tdriver"
  s.summary       =   GEM_SUMMARY
  s.require_path  =   "lib/testability-driver-plugins/"
  s.files         =   FileList[ 'env.rb', 'lib/**/*', 'xml/**/*' ].to_a
	s.has_rdoc      =   false

  if( @__release_mode == 'cruise' )
    s.add_dependency("testability-driver", "=#{ @__gem_version }")
  else
    s.add_dependency("testability-driver", ">=0.8.3")
  end

  s.extensions << 'installer/extconf.rb'
  
}

Rake::GemPackageTask.new( spec ) do | pkg |
  pkg.gem_spec = spec
  pkg.package_dir = "pkg"
end

task :default do | task |

  puts "supported tasks: cruise, cruise_linux, gem, gem_install, gem_uninstall, doc, behaviours"

end

def run_tdriver_devtools( params, tests )
  
  # reset arguments constant without warnings
  ARGV.clear; 
  
  unless tests.nil?
    ARGV << "-t"; ARGV << tests;
  end
  
  params.to_s.split(" ").each{ | argument | ARGV << argument }
    
  begin
    require File.expand_path( File.join( File.dirname( __FILE__ ), '../driver/lib/tdriver-devtools/tdriver-devtools.rb' ) )
  rescue LoadError
    begin
     require('tdriver/../tdriver-devtools/tdriver-devtools.rb')
    rescue LoadError
      abort("Unable to proceed due to TDriver not found or is too old! (required 0.9.2 or later)")
    end
  end
  
end

task :behaviours do | task |

  puts "\nGenerating behaviour XML files from implementation... "   

  run_tdriver_devtools( '-g behaviours lib behaviours', nil )

end


task :doc, :tests do | task, args |
  
  test_results_folder = args[ :tests ] || "../tests/test/feature_xml"
  
  if args[:tests].nil?
    puts "\nWarning: Test results folder not given, using default location (#{ test_results_folder })"
    puts "\nSame as executing:\nrake doc[#{ test_results_folder }]\n\n"
    sleep 1  
  else
    puts "Using given test results from #{ test_results_folder }"
  end
  
  test_results_folder = File.expand_path( test_results_folder )
  
  puts "\nGenerating documentation XML file..."

  run_tdriver_devtools( '-g both lib doc/document.xml', args[:tests] )
  
end

desc "Task for installing the generated gem"
task :gem_install do
  
  puts "#########################################################"
  puts "### Installing GEM  #{GEM_NAME}       ###"
  puts "#########################################################"
  tdriver_gem = "testability-driver-#{@__gem_version}.gem"
  if /win/ =~ RUBY_PLATFORM
     cmd = "gem install pkg\\tdriver*.gem --LOCAL"
  else
     cmd = "gem install pkg/tdriver*.gem --LOCAL"
  end
  failure = system(cmd)
  raise "installing  #{GEM_NAME} failed" if (failure != true) or ($? != 0)
  
end


desc "Task for installing the generated gem"
task :gem_uninstall do
  
  puts "#########################################################"
  puts "### Uninstalling GEM #{GEM_NAME}     ###"
  puts "#########################################################"
  tdriver_gem = "testability-driver-#{@__gem_version}.gem"
     
  FileUtils.rm(Dir.glob('pkg/*gem'))
  cmd = "gem uninstall -a -x #{GEM_NAME}"
  failure = system(cmd)
#  raise "uninstalling  #{GEM_NAME} failed" if (failure != true) or ($? != 0)
  
end



desc "Task for cruise control on Windows"
#task :cruise => ['unit_test', 'build_help', 'gem', 'gem_install', 'gem_copy_to_share'] do
task :cruise => ['gem_uninstall', 'gem', 'gem_install'] do
	
end

desc "Task for cruise control on Linux"
task :cruise_linux => ['gem_uninstall', 'gem', 'gem_install'] do    
	
end



