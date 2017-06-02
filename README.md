# wavefront-sdk [![Build Status](https://travis-ci.org/snltd/wavefront-sdk.svg?branch=master)](https://travis-ci.org/snltd/wavefront-sdk) [![Code Climate](https://codeclimate.com/github/snltd/wavefront-sdk/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-sdk/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Known Vulnerabilities](https://snyk.io/test/github/snltd/wavefront-sdk/badge.svg)](https://snyk.io/test/github/snltd/wavefront-sdk)

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

## Examples

First, let's list the IDs of the users in our account. The `list()` method
will return a `Wavefront::Response::User` object with a list of items. Most
response classes behave this way.

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

wf.list.response.items.each { |user| puts user[:identifier] }

# And delete the user 'lolex@oldplace.com'

wf.delete('lolex@oldplace.com')
```

Retrieve a timeseries over the last 10 minutes, with one minute bucket
granularity. We will describe the time as a Ruby object, but could also use
an epoch timestamp.


```ruby
require 'wavefront-sdk/query'

Wavefront::Query.new(CREDS).query(
  'ts("prod.www.host.tenant.physicalmem.usage")',
  :m,
  (Time.now - 600)
)
```

The SDK also provides a helper class for extracting credentials from a
configuration file:

```ruby
require 'wavefront-sdk/credentials'

# Get an object which contains credentials

Wavefront::Credentials.new.to_obj

# Now use that to list the proxies in our account

require 'pp'
require 'wavefront-sdk/proxy'

pp Wavefront::Proxy.new(c.creds).list
```

We can write points too, assuming we have a proxy. You can't write points
directly via the API. Unlike all other classes, this one requires the proxy
address and port as its credential hash.

```ruby
require 'wavefront-sdk/write'

W_CREDS = { proxy: 'wavefront.localnet', port: 2878 }

wf = Wavefront::Write.new(W_CREDS, debug: true)

task = wf.write( [{ path: 'dev.test.sdk', value: 10 }])

p task.response
#<struct sent=1, rejected=0, unsent=0>
puts task.status.result
#OK
```
