require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task default: :test

desc "Run example"
task :example do
  require 'rails_incoming_mail'
  server = RailsIncomingMail::Server.new('willemtest.ngrok.com', 25)
  server.start
  server.join
end
