# frozen_string_literal: true

# Automatically load all SDK classes.
#
require 'pathname'

libdir = Pathname.new(__dir__).join('wavefront-sdk')

libdir.children.select { |f| f.extname == '.rb' }.each do |f|
  require_relative f
end
