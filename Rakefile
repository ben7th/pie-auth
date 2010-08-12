require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('pie-auth', '0.1') do |p|
  p.description    = "used for User Auth in mindpin.com"
  p.url            = "http://github.com/ben7th/pie-auth"
  p.author         = "ben7th"
  p.email          = "ben7th@sina.com"
  p.ignore_pattern = ["tmp/*", "script/*", "nbproject/**/*.*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }