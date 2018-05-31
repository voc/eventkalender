# First include simplecov to track code coverage
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'rspec'
require 'webmock/rspec'
require 'rack/test'
require 'sinatra'
require 'haml'

%w{scraper fixnum}.each do |file|
  require File.join(File.dirname(__FILE__), '..', 'lib', 'eventkalender', "#{file}.rb")
end

%w{event meeting conference}.each do |file|
  require File.join(File.dirname(__FILE__), '..', 'lib', 'eventkalender', 'event', "#{file}.rb")
end

%w{parser meetings conferences}.each do |file|
  require File.join(File.dirname(__FILE__), '..', 'lib', 'eventkalender', 'parser', "#{file}.rb")
end

require File.join(File.dirname(__FILE__), '..', 'webapp.rb')

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.color = true
  config.order = 'random'

  # Create fake webserver to send serve all request local
  config.before(:each) do
    project_root             = File.expand_path('..', __FILE__)
    fixtures = {
      'https://c3voc.de/wiki/eventz'   => 'events.htm',
      'https://c3voc.de/wiki/meetingz' => 'meetings.htm'
    }

    fixtures.each do |url, file|
      stub_request(:get, url).to_return(:body => File.read("#{project_root}/fixtures/#{file}"), :status => 200, :headers => { 'Content-Type' => 'text/html; charset=utf-8'})
    end
  end
end

def app
  Sinatra::Application
end
