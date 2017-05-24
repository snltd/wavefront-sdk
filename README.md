# wavefront-sdk [![Build Status](https://travis-ci.org/snltd/wavefront-sdk.svg?branch=master)](https://travis-ci.org/snltd/wavefront-sdk) [![Code Climate](https://codeclimate.com/github/snltd/wavefront-sdk/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-sdk/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Known Vulnerabilities](https://snyk.io/test/github/snltd/wavefront-sdk/badge.svg)](https://snyk.io/test/github/snltd/wavefront-sdk)

This is a Ruby SDK for v2 of
[Wavefront](https://www.wavefront.com/)'s public API.

## Installation

```
$ gem install wavefront-sdk
```

or to build locally,

```
$ gem build wavefront-sdk.gemspec
```

## Examples

```ruby
# Define our API endpoint. (This is not a valid token!)

CREDS = { endpoint: 'metrics.wavefront.com',
          token: 'c7a1ff30-0dd8-fa60-e14d-f58f91bafc0e' }

# Retrieve a timeseries over the last 10 minutes, with one minute
# bucket granularity.

require 'wavefront-sdk/query'

wf = Wavefront::Query.new(CREDS)
wf.query('ts("prod.www.host.tenant.physicalmem.usage")', 'm',
        (Time.now - 600).to_i)

# List the users in our account

require 'wavefront-sdk/user'

wf = Wavefront::User.new(CREDS)
p wf.list

# And delete the user 'lolex@oldplace.com'

wf.delete('lolex@oldplace.com')
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
