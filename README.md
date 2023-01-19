# wavefront-sdk
[![Test](https://github.com/snltd/wavefront-sdk/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/snltd/wavefront-sdk/actions/workflows/test.yml) [![Release](https://github.com/snltd/wavefront-sdk/actions/workflows/release.yml/badge.svg?branch=master)](https://github.com/snltd/wavefront-sdk/actions/workflows/release.yml) [![Code Climate](https://codeclimate.com/github/snltd/wavefront-sdk/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-sdk/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Gem Version](https://badge.fury.io/rb/wavefront-sdk.svg)](https://badge.fury.io/rb/wavefront-sdk) ![](http://ruby-gem-downloads-badge.herokuapp.com/wavefront-sdk?type=total)

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

`wavefront-sdk` requires Ruby >= 2.7. All its dependencies are pure
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
`response` gives you the JSON response from the API, conveniently
processed and turned into a [`Map`](https://github.com/ahoward/map)
object. Map objects can be interrogated in various ways. For
instance `map['items']`, `map[:items]` and `map.items` will all get
you to the same place.

### Standard API Calls

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

puts proxies.ids
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
having to deal with pagination. When you do that, `offset` is repurposed as
the number of results fetched with each call to the API.

Calling a method with the limit set to `:lazy` returns a lazy
enumerable. Again, `offset` is the chunk size.

```ruby
wf = Wavefront::Alert.new(creds.all)

# The first argument is how many object to get with each API call,
# the second gets us a lazy #Enumerable
wf.list(99, :lazy).each { |alert| puts alert.name }
# Point Rate
# Disk Error
# ...
```

### Credentials

The SDK provides a helper class for extracting credentials from a
configuration file. If you don't supply a file, defaults will be
used. You can even override things with environment variables.

```ruby
require 'wavefront-sdk/credentials'

c = Wavefront::Credentials.new

# Now use that to list the alerts in our account

require 'wavefront-sdk/alert'

p Wavefront::Alert.new(c.creds).list

# To get proxy configuration, use the `proxy` method. This is
# required by the Write class. You can also use c.all, which
# includes proxy and API configuration.

wf = Wavefront::Write.new(c.proxy)
wf = Wavefront::Write.new(c.all)
```

### Queries

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

### Sending Metrics

The `Wavefront::Write` and `Wavefront::Distribution` classes lets
you send points to Wavefront in a number of ways.

#### Sending Points

Use `Wavefront::Write` to send points. Points are described as an
array of hashes. For example:

```ruby
wf = Wavefront::Write.new(Wavefront::Credentials.new.proxy)
wf.write([{ path: 'dev.test.sdk', value: 10 }])
```

The point hash also accepts optional `source`, `ts`, and `tag` keys.
`tag` is a hash describing point tags. For example.

```ruby
wf.write({ path:   'dev.test.sdk',
           value:  10,
           ts:     Time.now,
           source: 'example',
           tags:   { language: 'ruby',
                     level: 'beginner'})
```

As the example shows, if you are sending a single point, you can
send a naked hash, omitting the array syntax.

By default, `Wavefront::Write#write` will open a connection to
Wavefront on each call, closing it after use.

If you prefer to manage the connection yourself, supply `noauto:
true` in the options hash when instantiating the `Write` class.

```ruby
wf = Wavefront::Write.new(Wavefront::Credentials.new.proxy, noauto: true)
wf.open
wf.write(path: 'dev.test.sdk', value: 10)
wf.close
```

Alternatively, pass `false` as the second argument to `Write#write`.
(This is the legacy method, kept in for backward compatibility.)

```ruby
wf = Wavefront::Write.new(Wavefront::Credentials.new.proxy)
wf.open
wf.write([{ path: 'dev.test.sdk', value: 10 }], false)
wf.close
```

By default, `Write#write` speaks to a TCP socket on a nearby proxy,
but other methods are supported via the `writer` option.

```ruby
# To send points via the API
wf = Wavefront::Write.new(Wavefront::Credentials.new.creds, writer: :api)

# To send points via a local Unix socket
wf = Wavefront::Write.new({ socket: '/tmp/wf_sock'}, { writer: :socket })

# To send points over HTTP
wf = Wavefront::Write.new(Wavefront::Credentials.new.creds, writer: :http)

# Then call wf.write as before.
```

`Write` can output verbose and debug info, and the response object
provides a `summary` object.

```ruby
wf = Wavefront::Write.new(Wavefront::Credentials.new.proxy, verbose: true)
wf.write([{ path: 'dev.test.sdk', value: 11, tags: { tag1: 'mytag'} }])
# SDK INFO: dev.test.sdk 11 source=box tag1="mytag"

wf = Wavefront::Write.new(Wavefront::Credentials.new.proxy, debug: true)
wf.write([{ path: 'dev.test.sdk', value: 11, tags: { tag1: 'mytag'} }])
# SDK DEBUG: Connecting to wavefront:2878.
# SDK INFO: dev.test.sdk 11 source=box tag1="mytag"
# SDK DEBUG: Closing connection to proxy.

task = wf.write([{ path: 'dev.test.sdk_1', value: 1 },
                 { path: 'dev.test.sdk_2', value: 2 }])
p task.response
# {"sent"=>2, "rejected"=>0, "unsent"=>0}
puts task.ok?
# true
```

You can send delta metrics my prefixing your `path` with a delta
symbol, or by using the `Write#write_delta()` method. This is called in
exactly the same way as `Write#write`, and supports all the same
options.

If you try to send huge amounts of metrics in a single go,
`Wavefront::Write` will break them up into smaller API-friendly
chunks.

#### Sending Distributions

Use the `Wavefront::Distribution` class to send distributions via a
proxy. This is an extension of `Wavefront::Write`, so usage is
almost the same. All you have to do differently is specify an
interval size (`m`, `h`, or `d`), and use a distribution as your
`value`. We give you methods to help with this.  For instance:

```ruby
wf = Wavefront::Distribution.new(CREDS.proxy)

dist = wf.mk_distribution([7, 7, 7, 8, 8, 9, 10, 10])

p dist

# [[3, 7.0], [2, 8.0], [1, 9.0], [2, 10.0]]

p wf.write({ path: 'dev.test.dist', value: dist, interval: :m }).response
# {"sent"=>1, "rejected"=>0, "unsent"=>0}
```

#### Metric Helpers

The `Wavefront::MetricHelper` class gives you simple ways to write
metrics to in-memory buffers, and flush those buffer whenever you see
fit. It aims to be a little bit like Dropwizard.

`MetricHelper` gives you less control over the metrics you send. For
instance, the source and timestamp are automatically sent. You can
view the buffer at any time with the `buf` `attr_accessor`.

```ruby
require 'wavefront-sdk/metric_helper'

wf = Wavefront::MetricHelper.new(CREDS.proxy, verbose: true)

wf.gauge('my.gauge', 1)
wf.gauge('my.gauge', 2, { tag1: 'val1' })
wf.gauge('my.gauge', 3, { tag1: 'val2' })
wf.counter('my.counter')
wf.counter('my.counter', 1, { tag1: 'val1' } )
wf.counter('my.counter')

pp wf.buf

# {:gauges=>
#   [{:path=>"my.gauge", :ts=>1548633249, :value=>1},
#    {:path=>"my.gauge", :ts=>1548633249, :value=>2, :tags=>{:tag1=>"val1"}},
#    {:path=>"my.gauge", :ts=>1548633249, :value=>3, :tags=>{:tag1=>"val2"}}],
#  :counters=>{["my.counter", nil]=>2, ["my.counter", {:tag1=>"val1"}]=>1}}

wf.flush

# SDK INFO: my.gauge 1 1548633515 source=box
# SDK INFO: my.gauge 2 1548633515 source=box tag1="val1"
# SDK INFO: my.gauge 3 1548633515 source=box tag1="val2"
# SDK INFO: ∆my.counter 2 1548633515 source=box
# SDK INFO: ∆my.counter 1 1548633515 source=box tag1="val1"

pp wf.buf

# {:gauges=>[], :counters=>[]}
```

Note that gauges are sent individually, timestamped at the time they
are created. All counters are aggregated as you go along, and when
flushed, they send their value at that moment as a *single delta
metric*, the timestamp being the time of the flush.

You can also work with distributions. To do this, you must add
`dist_port` to your options hash, giving the number of the proxy
port listening for Wavefront format distributions. Numbers can be added
to distributions individually, or in an array. You must specify the
distribution interval.

```ruby
wf = Wavefront::MetricHelper.new(CREDS.proxy, { verbose: true, dist_port: 40000 })

wf.dist('my.dist', :m, 10)
wf.dist('my.dist', :m, 10)
wf.dist('my.dist', :m, [8, 8, 8, 9, 10, 10])
wf.dist('my.dist', :m, 8)

pp wf.buf

# {:gauges=>[],
#  :counters=>{},
#  :dists=>{["my.dist", :m, nil]=>[10, 10, 8, 8, 8, 9, 10, 10, 8]}}

wf.flush

# SDK INFO: !M 1548634226 #4 10.0 #4 8.0 #1 9.0 my.dist source=box
```

## Contributing

Fork it, fix it, send me a PR. Please supply tests, and try to keep
[Rubocop](https://github.com/bbatsov/rubocop) happy.
