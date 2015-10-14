# This format string fails to work with ApacheLogRegex, but would allow easier seperateion of method, url, protocol 
# format = '%h %l %u %t \" %m %U%q %H \" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
# hash['method'] = tokenized_line["%m"]
# hash['url'] = tokenized_line["%U%q"]
# hash['protocol'] = tokenized_line["%H"]
