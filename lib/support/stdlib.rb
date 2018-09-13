require 'pathname'

(Pathname.new(__FILE__).dirname + 'stdlib').realpath.children.each do |f|
  require f if f.extname == '.rb'
end
