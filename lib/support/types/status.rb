module Wavefront
  #
  # Status types are used by the Wavefront::Response class. They
  # represent the success or failure of an API call.
  #
  #
  module Type
    #
    # An object which provides information about whether the request
    # was successful or not. Ordinarily this is easy to construct
    # from the API's JSON response, but some classes, for instance
    # Wavefront::Write fake it by constructing their own.
    #
    # @!attribute [r] result
    #   @return [OK, ERROR] a string telling us how the request went
    # @!attribute [r] message
    #   @return [String] Any informational message from the API
    # @!attribute [r] code
    #   @return [Integer] the HTTP response code from the API
    #     request
    #
    class Status
      attr_reader :obj, :status

      # @param response [Hash] the API response, turned into a hash
      # @param status [Integer] HTTP status code
      #
      def initialize(response, status)
        @obj = response.fetch(:status, response)
        @status = status
      end

      def to_s
        obj.inspect.to_s
      end

      def message
        obj[:message] || nil
      end

      def code
        obj[:code] || status
      end

      def result
        return obj[:result] if obj[:result]
        return 'OK' if status.between?(200, 299)
        'ERROR'
      end
    end
  end
end
