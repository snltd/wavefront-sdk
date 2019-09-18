# frozen_string_literal: true

require_relative 'string'

# Extensions to stdlib Hash
#
class Hash
  # Convert a tag hash into a string. The quoting is recommended in
  # the WF wire-format guide. No validation is performed here.
  #
  def to_wf_tag
    map { |k, v| format('%s="%s"', k, v.tagescape) }.join(' ')
  end

  # Drop any key-value pairs where the value is not truthy
  #
  def cleanse
    select { |_k, v| v }
  end
end
