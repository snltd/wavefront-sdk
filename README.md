# wavefront-sdk [![Build Status](https://travis-ci.org/snltd/wavefront-sdk.svg?branch=master)](https://travis-ci.org/snltd/wavefront-sdk) [![Code Climate](https://codeclimate.com/github/snltd/wavefront-sdk/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-sdk/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Known Vulnerabilities](https://snyk.io/test/github/snltd/wavefront-sdk/badge.svg)](https://snyk.io/test/github/snltd/wavefront-sdk)

This is a Ruby SDK for [Wavefront](https://www.wavefront.com/)'s
public API.

The code is based on [the original Ruby
SDK](https://github.com/wavefrontHQ/ruby-client), to which I was a
major contributor. That
[wavefront-client](https://rubygems.org/gems/wavefront-client/) gem
was for v1 of the API, which has been obsoleted, and rather than try
to drag the old, messy codebase up to the new spec, it seemed more
sensible to start again.

This new SDK aims to address the issues of the previous one by
providing consistent interfaces, cleaner, DRYer, easier to
understand internals, and support for version 2 of the API.

This SDK goes beyond the common generated-from-Swagger approach,
providing programmer-friendly interfaces, automatic input
validation, and other, hopefully helpful, features.

I aim to fully implement all API paths, and the SDK will also
include methods to facilitate writing points to a Wavefront proxy,
which is not a feature of the API.

I also intend to make the best Ruby project I can, with full unit
test coverage (Minitest); machine-linted code (Rubocop and
[Codeclimate](https://codeclimate.com/github/snltd/wavefront-sdk)
and API documentation with [YARD](http://yardoc.org/).

Some functionality of the old gem is dropped, like Graphite and
Highcharts integrations, and support for Ruby < 2.2.

There's no gem as yet: the coverage is too incomplete.

## Status

| API path    | API Coverage | tests   | CLI coverage | RDoc coverage |
| ----------- | ------------ | ------- | ------------ | ------------- |
| Agent       | full         | full    | full         | full          |
| Alert       | full         | full    | full         | full          |
| Cloud       | full         | full    | full         | full          |
| Dashboard   | full         | full    | partial      | full          |
| Event       | full         | full    | none         | full          |
| External    | full         | full    | none         | full          |
| Maintenance | full         | full    | none         | full          |
| Message     | full         | full    | none         | full          |
| Metric      | full         | full    | none         | full          |
| Query       | full         | full    | none         | full          |
| Saved       | full         | full    | none         | full          |
| Search      | none         | none    | none         | none          |
| Source      | none         | none    | none         | none          |
| User        | none         | none    | none         | none          |
| Webhook     | none         | none    | none         | none          |

## CLI

This SDK provides the base for [a Wavefront
CLI](https://github.com/snltd/wavefront-cli). The old
`wavefront-client` combined the SDK and CLI.
