#!/usr/bin/env ruby

require 'apachelogregex'
require 'pp'
require 'json'
require 'date'
require 'time'

logfile = ARGV[0]



#http://httpd.apache.org/docs/2.2/logs.html
format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'


  #   format = '%h %l %u %t \" %m %U%q %H \" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
  #   hash['method'] = tokenized_line["%m"]
  #   hash['url'] = tokenized_line["%U%q"]
  #   hash['protocol'] = tokenized_line["%H"]



@parser = ApacheLogRegex.new(format)
@line_hashes = []

def line_to_formatted_hash(line)

    tokenized_line =  @parser.parse(line)

    hash = Hash.new

    #split request into method, url, protocol

    request = tokenized_line["%r"]
    method = request.split(' ')[0]
    url = request.split(' ')[1]
    protocol =  request.split(' ')[2]

    hash['method'] = method
    hash['url'] = url
    hash['protocol'] = protocol

    #fields that can be copied directly

    hash['remote'] = tokenized_line["%h"]
    hash['identity'] = tokenized_line["%l"]
    hash['user'] = tokenized_line["%u"]
    hash['referer'] = tokenized_line["%{Referer}i"]
    hash['user-agent'] = tokenized_line["%{User-Agent}i"]


    #fields that require type conversion

    hash['status'] = tokenized_line["%>s"].to_i
    hash['bytes'] = tokenized_line["%b"].to_i



   # convert apache date string to UTC ISO 8601 time

    apache_date_string = tokenized_line["%t"]
    puts apache_date_string
    date_time = DateTime.strptime( apache_date_string, "[%d/%b/%Y:%H:%M:%S %Z]")
    iso8601_time = date_time.to_time.utc.iso8601

    hash['date'] = iso8601_time 



    hash



end


File.foreach logfile do |line|

      formatted_hash = line_to_formatted_hash(line)
      @line_hashes << formatted_hash

end


@line_hashes.each do |h|

  pp h#.to_json
  puts '-----------'

end