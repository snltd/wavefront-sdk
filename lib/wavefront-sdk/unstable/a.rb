#!/usr/bin/env ruby

require_relative '../credentials'
require_relative '../proxy'
require_relative 'chart'

creds = Wavefront::Credentials.new

wf = Wavefront::Unstable::Chart.new(creds.creds, verbose: true)

pp wf.metrics_under('dev.test').response

#wf = Wavefront::Proxy.new(creds.creds, verbose: true)
#
#pp  wf.list.status
