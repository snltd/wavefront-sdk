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

CREDS = { endpoint: 'https://metrics.wavefront.com',
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

## Status

### Wavefront API Coverage

| API path           | Coverage | tests | CLI     | RDoc |
| ------------------ | -------- | ----- | ------- | ---- |
| Alert              | full     | full  | full    | full |
| Cloud Integration  | full     | full  | full    | full |
| Dashboard          | full     | full  | partial | full |
| Event              | full     | full  | none    | full |
| External Link      | full     | full  | full    | full |
| Maintenance Window | full     | full  | none    | full |
| Message            | full     | full  | none    | full |
| Metric             | full     | full  | none    | full |
| Proxy              | full     | full  | full    | full |
| Query              | full     | full  | none    | full |
| Saved Search       | full     | full  | none    | full |
| Search             | full     | full  | none    | full |
| Source             | full     | full  | none    | full |
| User               | full     | full  | none    | full |
| Webhook            | full     | full  | none    | full |

### Additional Coverage

The following are classes which do not cover a Wavefront API path.

| SDK class | Coverage | tests | CLI  | RDoc |
| --------- | -------- | ----- | ---- | ---- |
| write     | full     | full  | none | full |


## CLI

This SDK provides the base for [a Wavefront
CLI](https://github.com/snltd/wavefront-cli). The old
`wavefront-client` combined the SDK and CLI.
