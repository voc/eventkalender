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

require File.join(File.dirname(__FILE__), '..', 'lib', 'eventkalender', 'parser.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'eventkalender', 'scraper.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'eventkalender', 'event.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'eventkalender', 'fixnum.rb')
require File.join(File.dirname(__FILE__), '..', 'webapp.rb')

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.color_enabled = true
  config.order = 'random'

  # Create fake webserver to send serve all request local
  config.before(:each) do
    project_root     = File.expand_path('..', __FILE__)
    events_html_file = "#{project_root}/fixtures/events.htm"

    stub_request(:get, 'http://c3voc.de/wiki/events').to_return( body: File.read(events_html_file),
                                                                 code: 200,
                                                                 headers: { 'Content-Type' =>
                                                                            'text/html; charset=utf-8'} )
  end
end

def app
  Sinatra::Application
end