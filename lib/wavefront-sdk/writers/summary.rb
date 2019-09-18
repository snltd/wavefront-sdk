# frozen_string_literal: true

module Wavefront
  module Writer
    #
    # Count and report on points we attempt to send to Wavefront.
    #
    class Summary
      attr_accessor :sent, :rejected, :unsent

      def initialize
        @sent     = 0
        @rejected = 0
        @unsent   = 0
      end

      # @return [String] OK if all points were sent, ERROR if not
      #
      def result
        ok? ? 'OK' : 'ERROR'
      end

      # Were all points sent successfully? (This does not
      # necessarily mean they were received -- it depends on the
      # writer class. Sockets are dumb, HTTP is smart.)
      # @return [Bool]
      #
      def ok?
        unsent.zero? && rejected.zero?
      end

      # Representation of summary as it used to be when it was built
      # into the Write class
      # @return [Hash]
      #
      def to_h
        { sent: sent, rejected: rejected, unsent: unsent }
      end
    end
  end
end
