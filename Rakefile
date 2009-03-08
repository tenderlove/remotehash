# -*- ruby -*-

require 'rubygems'
require 'hoe'

$: << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'remotehash'

HOE = Hoe.new('remotehash', RemoteHash::VERSION) do |p|
  p.developer('Aaron Patterson', 'aaronp@rubyforge.org')
  p.readme_file   = 'README.rdoc'
  p.history_file  = 'CHANGELOG.rdoc'
  p.extra_rdoc_files  = FileList['*.rdoc']
end

namespace :gem do
  namespace :spec do
    task :dev do
      File.open("#{HOE.name}.gemspec", 'w') do |f|
        HOE.spec.version = "#{HOE.version}.#{Time.now.strftime("%Y%m%d%H%M%S")}"
        f.write(HOE.spec.to_ruby)
      end
    end
  end
end

# vim: syntax=Ruby
