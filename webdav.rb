#!/usr/bin/env ruby
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
# net_digest_auth.rb
require 'digest/md5'

require 'net/http'

begin
  require 'net/https'
  $webdav_upload_disabled = true
rescue LoadError 
  #apt-get install libopenssl-ruby
  warn("Warning: Disabling WebDAV uploading due to net/https module not available; install libopenssl-ruby libraries or similar depending of the OS")
end

require 'uri'

class DavUpload
  attr_accessor :http

  def initialize(proxy_host,proxy_port,target_host,target_port)

    @http = Net::HTTP::Proxy(proxy_host, proxy_port).new(target_host,target_port)
    @http.use_ssl = true
  end

  def upload_file(src, target)
    file=File.open(src)

    if file.respond_to? :read
      file.rewind
      stream = file
      length = File.size file.path
    else
      stream = File.open(file,"rb")
      length = File.size file
    end

    req = Net::HTTP::Put.new(target)
    req.basic_auth(@username, @password)
    #req.body_stream     = stream
    req.content_length  = length
    p length
    req["Content-Type"] = "application/octet-stream"
    req['Transfer-Encoding'] = 'chunked'
    
    resp = @http.request(req,File.open(src,"rb").read)
    p resp.code
    p resp.message    
    
  end



  def create_dir(target)
    req = Net::HTTP::Mkcol.new(target)
    req.basic_auth(@username, @password)
    response = @http.request(req)
  end

  def move_dir(target, new_target)
    req = Net::HTTP::Move.new(target)
    req.basic_auth(@username, @password)
    response = @http.request(req, new_target)
  end

  def remove_dir(target)
    req = Net::HTTP::Delete.new(target)
    req.basic_auth(@username, @password)
    resp = @http.request(req)
    p resp.code
    p resp.message
  end

  def upload_dir(src, target)

    Dir.foreach(src) do |file|
      if((file == ".") or (file == ".."))
        next
      end

      new_src = src+ "/" + file
      new_target = target + "/" + file
      new_target.gsub!(/ /,'%20')
      puts new_src
      puts new_target
      if(File.directory? new_src)
        puts "dir detected"
        create_dir(new_target)
        upload_dir(new_src, new_target)
      else
        upload_file(new_src, new_target)
      end
    end
  end

  def auth(username, password)
    @username = username
    @password = password
  end

end

module DocumentDavupload

  def initialize_public_address    
    @proxy_port = 8080
    @target_host = 'projects.forum.nokia.com'
    @target_port = '443'
  end

  def upload_doc_to_public_dav(username,password,doc,version,proxy)
     puts "Initialize connection attributes..."
	 @proxy_host=proxy
     initialize_public_address()
    
     trgt_fldr = "/dav/Testabilitydriver/doc/api/#{doc}"
     puts "Initialize connection..."
     dav = DavUpload.new(@proxy_host, @proxy_port, @target_host, @target_port)
     dav.auth(username,password)
     puts "Moving old documentation from #{trgt_fldr} to /dav/Testabilitydriver/release/#{version}/doc/api/#{doc}..."
     dav.move_dir(trgt_fldr,"/dav/Testabilitydriver/release/#{version}/doc/api/#{doc}")   
     puts "Uploading new documentation to #{trgt_fldr}"
     dav.upload_dir("/doc/output",trgt_fldr)   
     
  end

end







