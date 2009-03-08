# -*- ruby -*-

require 'rubygems'
require 'hoe'

$: << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'remotehash'

Hoe.new('remotehash', RemoteHash::VERSION) do |p|
  p.developer('Aaron Patterson', 'aaronp@rubyforge.org')
  p.readme_file   = 'README.rdoc'
  p.history_file  = 'CHANGELOG.rdoc'
  p.extra_rdoc_files  = FileList['*.rdoc']
end

# vim: syntax=Ruby
