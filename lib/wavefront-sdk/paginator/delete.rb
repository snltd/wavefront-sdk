require_relative 'base'

module Wavefront
  module Paginator
    #
    # As far as I know, there are no DELETE methods with paginated
    # output.
    #
    class Delete < Base; end
  end
end
