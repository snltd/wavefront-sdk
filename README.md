# wavefront-sdk
[![Build Status](https://travis-ci.org/snltd/wavefront-sdk.svg?branch=master)](https://travis-ci.org/snltd/wavefront-sdk) [![Code Climate](https://codeclimate.com/github/snltd/wavefront-sdk/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-sdk/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Dependency Status](https://gemnasium.com/badges/github.com/snltd/wavefront-sdk.svg)](https://gemnasium.com/github.com/snltd/wavefront-sdk) [![Gem Version](https://badge.fury.io/rb/wavefront-sdk.svg)](https://badge.fury.io/rb/wavefront-sdk) ![](http://ruby-gem-downloads-badge.herokuapp.com/wavefront-sdk?type=total)

This is a Ruby SDK for v2 of
[Wavefront](https://www.wavefront.com/)'s public API. It supports Ruby >= 2.2.

Note that it currently has major version number `0`. This means *it
is not finished*. Until version `1` comes out, I reserve the right
to change, break, and befoul the code and the gem.

## Installation

```
$ gem install wavefront-sdk
```

or to build locally,

```
$ gem build wavefront-sdk.gemspec
```

## Documentation

The code is documented with [YARD](http://yardoc.org/) and
automatically generated documentation is [available on
rubydoc.info](http://www.rubydoc.info/gems/wavefront-sdk/).

## Examples

First, let's list the IDs of the users in our account. The `list()`
method will return a `Wavefront::Response` object. This object has
`status` and `response` methods. `status` always yields a structure
containing `result`, `message` and `code` fields which can be
inspected to ensure an API call was processed successfully.
`response` gives you a the JSON response from the API, conveniently
processed and turned into a [`Map`](https://github.com/ahoward/map)
object. Map objects can be interrogated in various ways. For
instance `map['items']`, `map[:items]` and `map.items` will all get
you to the same place.


```ruby
# Define our API endpoint. (This is not a valid token!)

CREDS = { endpoint: 'metrics.wavefront.com',
          token: 'c7a1ff30-0dd8-fa60-e14d-f58f91bafc0e' }

require 'wavefront-sdk/user'

# You can pass in a Ruby logger object, and tell the SDK to be
# verbose.

require 'logger'
log = Logger.new(STDOUT)

wf = Wavefront::User.new(CREDS, verbose: true, logger: log)

# See how things went:

p wf.status
#<Wavefront::Type::Status:0x007feb99185538 @result="OK", @message="", @code=200>

# And print each user's ID

wf.list.response.items.each { |user| puts user[:identifier] }

# Now delete the user 'lolex@oldplace.com', disregarding the
# response.

wf.delete('lolex@oldplace.com')
```

Retrieve a timeseries over the last 10 minutes, with one minute bucket
granularity. We will describe the time as a Ruby object, but could also use
an epoch timestamp. The SDK happily converts between the two.


```ruby
require 'wavefront-sdk/query'

Wavefront::Query.new(CREDS).query(
  'ts("prod.www.host.tenant.physicalmem.usage")',
  :m,
  (Time.now - 600)
)
```

We can write points too, assuming we have access to a proxy, because
you can't write points directly via the API. Unlike all other classes, this
one requires the proxy address and port as its credential hash.

```ruby
require 'wavefront-sdk/write'

W_CREDS = { proxy: 'wavefront.localnet', port: 2878 }

wf = Wavefront::Write.new(W_CREDS, debug: true)

task = wf.write( [{ path: 'dev.test.sdk', value: 10 }])

p task.response
#{"sent"=>1, "rejected"=>0, "unsent"=>0}
puts task.status.result
#OK
```

The SDK also provides a helper class for extracting credentials from a
configuration file. If you don't supply a file, defaults will be
used.

```ruby
require 'wavefront-sdk/credentials'

c = Wavefront::Credentials.new

# Now use that to list the proxies in our account

require 'wavefront-sdk/proxy'

p Wavefront::Proxy.new(c.creds).list

# It works for proxies too:

wf = Wavefront::Write.new(c.proxy)
```
