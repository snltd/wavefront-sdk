require_relative 'string'

# Extensions to stdlib Hash
#
class Hash
  # Convert a tag hash into a string. The quoting is recommended in
  # the WF wire-format guide. No validation is performed here.
  #
  # rubocop:disable Style/FormatStringToken
  def to_wf_tag
    map { |k, v| format('%s="%s"', k, v.tagescape) }.join(' ')
  end
end
