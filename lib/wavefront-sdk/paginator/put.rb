# frozen_string_literal: true

require_relative 'base'

module Wavefront
  module Paginator
    #
    # As far as I know, there are no PUT methods with paginated
    # output.
    #
    class Put < Base; end
  end
end
