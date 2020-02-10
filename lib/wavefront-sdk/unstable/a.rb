#!/usr/bin/env ruby

require_relative '../credentials'
require_relative '../proxy'
require_relative 'chart'
require_relative 'spy'

creds = Wavefront::Credentials.new

#wf = Wavefront::Unstable::Chart.new(creds.creds, verbose: true)
wf = Wavefront::Unstable::Spy.new(creds.creds, debug: true, verbose: true)

wf.points(0.05)

#pp wf.metrics_under('dev.test').response

#wf = Wavefront::Proxy.new(creds.creds, verbose: true)
#
#pp  wf.list.status
