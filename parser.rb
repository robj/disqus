#!/usr/bin/env ruby

require 'apachelogregex'
require 'pp'
require 'json'

logfile = ARGV[0]



#http://httpd.apache.org/docs/2.2/logs.html
format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
#format = '%h %l %u %t \" %m %U%q %H \" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'



@parser = ApacheLogRegex.new(format)
@line_hashes = []

def line_to_hash(line)

    tokenized_line =  @parser.parse(line)
   # puts tokenized_line['\"%{Referer}i\']
  #  pp tokenized_line

     request = tokenized_line["%r"]
     method = request.split(' ')[0]
     url = request.split(' ')[1]
     protocol =  request.split(' ')[2]

     hash = Hash.new

     hash['remote'] = tokenized_line["%h"]
     hash['identity'] = tokenized_line["%l"]
     hash['user'] = tokenized_line["%u"]
     hash['date'] = tokenized_line["%t"].gsub('[','').gsub(']','')
     hash['status'] = tokenized_line["%>s"].to_i
     hash['bytes'] = tokenized_line["%b"].to_i
     hash['referer'] = tokenized_line["%{Referer}i"]
     hash['user-agent'] = tokenized_line["%{User-Agent}i"]

     hash['method'] = method
     hash['url'] = url
     hash['protocol'] = protocol


  #   hash['method'] = tokenized_line["%m"]
  #   hash['url'] = tokenized_line["%U%q"]
  #   hash['protocol'] = tokenized_line["%H"]

     @line_hashes << hash

end


File.foreach logfile do |line|

      line_to_hash(line)

end


@line_hashes.each do |h|

  pp h#.to_json
  puts '-----------'

end