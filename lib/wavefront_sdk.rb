# Automatically load all SDK classes.
#
require 'pathname'

libdir = Pathname.new(__FILE__).dirname + 'wavefront-sdk'

libdir.children.select { |f| f.extname == '.rb' }.each do |f|
  require_relative f
end
