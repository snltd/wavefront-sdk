# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # Manage and query the Wavefront access policy
  #
  class AccessPolicy < CoreApi
    # GET /api/v2/accesspolicy
    # Get the access policy
    # @return [Wavefront::Response]
    #
    def describe
      api.get('')
    end

    # PUT /api/v2/accesspolicy
    # Update the access policy
    # @param body [Hash] hash describing access policy
    # @return [Wavefront::Response]
    #
    def update(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.put('', body, 'application/json')
    end

    # GET /api/v2/accesspolicy/validate
    # Validate a given url and ip address
    # @return [Wavefront::Response]
    #
    def validate(ip)
      api.get('validate', ip: ip)
    end
  end
end
