require_relative 'core/write'

module Wavefront
  #
  # This class helps you send points direct to the Wavefront API.
  #
  # The points are prepped in the BaseWrite class, which this
  # extends. This class provides the transport mechanism.
  #
  class Report < CoreWrite
    def api_path
      '/report'
    end

    def write(points = [], _openclose = true, prefix = nil)
      _write_loop(prepped_points(points, prefix))
    end

    def really_send_point(point)
      api.post('/?f=wavefront', point, 'application/octet-stream')
    end

    private

    # Because API calls are expensive (compared to hitting a local
    # proxy) we will bundle up points into a single call.
    #
    def _write_loop(points)
      send_point(points.map { |p| hash_to_wf(p) }.join("\n"))
    end
  end
end
