# wavefront-sdk [![Build Status](https://travis-ci.org/snltd/wavefront-sdk.svg?branch=master)](https://travis-ci.org/snltd/wavefront-sdk) [![Code Climate](https://codeclimate.com/github/snltd/wavefront-sdk/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-sdk) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-sdk/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-sdk)

This is a Ruby SDK for [Wavefront](https://www.wavefront.com/)'s
public API.

The code is based on [the original Ruby
SDK](https://github.com/wavefrontHQ/ruby-client), to which I was a
major contributor, but I don't know how much of it that be left by
the end.

This new SDK aims to address the issues of the previous one by
providing consistent interfaces, cleaner, DRYer, easier to
understand internals, and support for version 2 of the API.

The SDK goes beyond the common generated-from-Swagger approach,
providing programmer-friendly interfaces, automatic input
validation, and other, hopefully helpful, features.

I aim to fully implement all API paths, and the SDK will also
include methods to facilitate writing points to a Wavefront proxy,
which is not a feature of the API.

I also intend to make the best Ruby project I can, with full unit
test coverage (Minitest); machine-linted code (Rubocop and
[Codeclimate](https://codeclimate.com/github/snltd/wavefront-sdk)
and API documentation ([YARD](http://yardoc.org/).

## Status

| API path    | API Coverage | tests   | CLI coverage | RDoc coverage |
| ----------- | ------------ | ------- | ------------ | ------------- |
| Agent       | full         | full    | full         | full          |
| Alert       | partial      | partial | partial      | none          |
| Cloud       | none         | none    | none         | none          |
| Dashboard   | none         | none    | none         | none          |
| Event       | none         | none    | none         | none          |
| External    | none         | none    | none         | none          |
| Maintenance | none         | none    | none         | none          |
| Message     | none         | none    | none         | none          |
| Metric      | none         | none    | none         | none          |
| Query       | none         | none    | none         | none          |
| Saved       | none         | none    | none         | none          |
| Search      | none         | none    | none         | none          |
| Source      | none         | none    | none         | none          |
| User        | none         | none    | none         | none          |
| Webhook     | none         | none    | none         | none          |

## CLI

This SDK provides the base for [a Wavefront
CLI](https://github.com/snltd/wavefront-cli). The old
`wavefront-client` combined the SDK and CLI.
