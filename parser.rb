#!/usr/bin/env ruby

require 'apachelogregex'
require 'json'
require 'date'
require 'time'


# http://httpd.apache.org/docs/2.2/logs.html
# reuse a single instance of the parser

format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
@parser = ApacheLogRegex.new(format)



formatted_hashes = []


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
    date_time = DateTime.strptime( apache_date_string, "[%d/%b/%Y:%H:%M:%S %Z]")
    iso8601_time = date_time.to_time.utc.iso8601

    hash['date'] = iso8601_time 


    # set '-' values to nil

    hash.each do |k,v|

      hash[k] = nil if hash[k] == '-'

    end



    hash



end



# read from stdin and create formatted hashes 

ARGF.each do |line|

      formatted_hash = line_to_formatted_hash(line)
      formatted_hashes << formatted_hash

end



formatted_hashes.each do |h|

  puts h.to_json + "\n"

end


