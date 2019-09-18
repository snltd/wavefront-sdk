# frozen_string_literal: true

# Extensions to stdlib String
#
class String
  # Join strings together to make a URI path in a way that is more
  # flexible than URI::Join.  Removes multiple and trailing
  # separators. Does not have to produce fully qualified paths. Has
  # no concept of protocols, hostnames, or query strings.
  #
  # @return [String] a URI path
  #
  def tagescape
    gsub(/"/, '\"')
  end
end
