# wavefront-sdk
[![Build Status](https://travis-ci.org/snltd/wavefront-sdk.svg?branch=master)](https://travis-ci.org/snltd/wavefront-sdk) [![Code Climate](https://codeclimate.com/github/snltd/wavefront-sdk/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-sdk/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Gem Version](https://badge.fury.io/rb/wavefront-sdk.svg)](https://badge.fury.io/rb/wavefront-sdk) ![](http://ruby-gem-downloads-badge.herokuapp.com/wavefront-sdk?type=total)

This is a Ruby SDK for v2 of
[Wavefront](https://www.wavefront.com/)'s public API. It aims to be
more lightweight, consistent, simple, and convenient than an
auto-generated SDK.

As well as complete API coverage, `wavefront-sdk` includes methods
which facilitate various common tasks, and provides non-API
features such as credential management, and writing points through a
proxy. It also has methods mimicking the behaviour of useful v1 API
calls which did not make it into v2.

## Installation

```
$ gem install wavefront-sdk
```

or to build locally,

```
$ gem build wavefront-sdk.gemspec
```

`wavefront-sdk` requires Ruby >= 2.2. All its dependencies are pure
Ruby, right the way down, so a compiler should never be required to
install it.

## Documentation

The code is documented with [YARD](http://yardoc.org/) and
automatically generated documentation is [available on
rubydoc.info](http://www.rubydoc.info/gems/wavefront-sdk/).

## Examples

First, let's list the Wavefront proxies in our account. The `list()`
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

require 'wavefront-sdk/proxy'

# You can pass in a Ruby logger object, and tell the SDK to be
# verbose.

require 'logger'
log = Logger.new(STDOUT)

wf = Wavefront::User.new(CREDS, verbose: true, logger: log)
proxies = wf.list

puts proxies.class
# Wavefront::Response

# See how things went. How specific do you want to be?

puts proxies.ok?
# true
puts proxies.empty?
# false
puts proxies.status
# {:result=>"OK", :message=>"", :code=>200}
puts proxies.status.code
# 200

# Now print the proxy IDs

puts proxies.names
# 1439acb2-ab07-4cf9-8397-2f2d758e52a0
# 87eca9df-fc47-4a24-88cf-6dd0bae245a9
# df77bd37-8f32-4e0c-b578-51eb42f22b6f

# Delete the first one.

result = wf.delete('1439acb2-ab07-4cf9-8397-2f2d758e52a0')
puts result.ok?
# true
```

By default (because it's the default behaviour of the API),
all API classes (except `user`) will only return blocks of results
when you ask for a list of objects.

You can set an offset and a limit when you list, but setting the
limit to the magic value `:all` will return all items, without you
having to deal with pagination.

Calling a method with the limit set to `:lazy` returns a lazy
enumerable.

```ruby
wf = Wavefront::Alert.new(creds.all)

# The first argument is how many object to get with each API call,
# the second gets us a lazy #Enumerable
wf.list(99, :lazy).each { |alert| puts alert.name }
# Point Rate
# Disk Error
# ...
```

We can easily write queries. Let's retrieve a timeseries over the
last 10 minutes, with one minute bucket granularity. We will
describe the time as a Ruby object, but could also use an epoch
timestamp. The SDK happily converts between the two.


```ruby
require 'wavefront-sdk/query'

Wavefront::Query.new(CREDS).query(
  'ts("prod.www.host.tenant.physicalmem.usage")',
  :m,
  (Time.now - 600)
)
```

We can write points too. The `Write` class lets you send points to a
proxy, and the `Report` class sends them directly via the API.
Unlike all other classes, `Write` requires the proxy address and
port as its credential hash. `Report` has the same methods and works
in the same way, but uses the same credentials as all the other
classes.

```ruby
require 'wavefront-sdk/write'

W_CREDS = { proxy: 'wavefront.localnet', port: 2878 }

wf = Wavefront::Write.new(W_CREDS, verbose:true)

task = wf.write( [{ path: 'dev.test.sdk', value: 10 }])
# SDK DEBUG: Connecting to wavefront.localnet:2878.
# SDK INFO: dev.test.sdk 10 source=box
# SDK DEBUG: Closing connection to proxy.
puts task.response
# {"sent"=>1, "rejected"=>0, "unsent"=>0}
puts task.ok?
# true
```

You can send delta metrics either by manually prefixing your metric
path with a delta symbol, or by using the `write_delta()` method.
There is even a class to help you write Wavefront distributions.

You can also send points to a local proxy over HTTP. Just specify
`:http` as the `writer` option when you create your write object.

```ruby
wf = Wavefront::Write.new(W_CREDS, writer: :http, verbose: true)

task = wf.write( [{ path: 'dev.test.sdk', value: 10 }])
# SDK INFO: dev.test.sdk 10 source=box
# SDK INFO: uri: POST http://wavefront.localnet:2878/
# SDK INFO: body: dev.test.sdk 10 source=box
p task.response
# {"sent"=>1, "rejected"=>0, "unsent"=>0}
puts task.ok?
# true
```

The SDK provides a helper class for extracting credentials from a
configuration file. If you don't supply a file, defaults will be
used. You can even override things with environment variables.

```ruby
require 'wavefront-sdk/credentials'

c = Wavefront::Credentials.new

# Now use that to list the proxies in our account

require 'wavefront-sdk/proxy'

p Wavefront::Proxy.new(c.creds).list

# It works for proxies too:

wf = Wavefront::Write.new(c.proxy)
```

## Contributing

Fork it, fix it, send me a PR. Please supply tests, and try to keep
[Rubocop](https://github.com/bbatsov/rubocop) happy.
