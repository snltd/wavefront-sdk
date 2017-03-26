# wavefront-sdk [![Build Status](https://travis-ci.org/snltd/wavefront-sdk.svg?branch=master)](https://travis-ci.org/snltd/wavefront-sdk)

This is a Ruby SDK for [Wavefront](https://www.wavefront.com/)'s
public API.

The code is based on [the original Ruby
SDK](https://github.com/wavefrontHQ/ruby-client), to which I was a
major contributor.

The code aims to address the issues of the previous SDK, by
providing consistent, DRY interfaces, cleaner, easier to understand
internals, and support for version 2 of the API.

It aims to go beyond the generated-from-Swagger approach of many
SDKs by providing simple interfaces, automatic input validation, and
other, hopefully, helpful features.

I aim to fully implement all API paths.

This SDK provides the base for [a Wavefront
CLI](https://github.com/snltd/wavefront-cli).
