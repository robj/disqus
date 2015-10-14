##### Dependencies

```bash
gem install apachelogregex
```


##### Usage

```bash
cat access.log | ./parser > access.json
```


##### Notes

* Tested with Ruby 2.2
* As per spec, output is newline seperated JSON blobs (not a valid JSON array)


