# frozen_string_literal: true

require_relative 'write'

module Wavefront
  #
  # This class is now a shim around Wavefront::Write, which forces
  # the use of the Wavefront::Writer::Api writer. It is probably
  # better to use Wavefront::Write directly. This class has been
  # left in for backward-compatability.
  #
  class Report < Write
    def initialize(creds = {}, opts = {})
      opts[:writer] = :api
      super(creds, opts)
    end
  end
end
