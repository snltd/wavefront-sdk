# frozen_string_literal: true

require_relative 'base'

module Wavefront
  module Paginator
    #
    # GET pagination is handled in the Base class without further
    # modification.
    #
    class Get < Base; end
  end
end
