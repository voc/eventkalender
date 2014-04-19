require 'sinatra'
require 'haml'
require_relative 'lib/eventkalender'

set :views,  File.dirname(__FILE__) + '/views'
set :parser, Eventkalender::Parser.new

# HTML pages
get '/' do
  haml :index
end

get '/events.html' do
  haml :events
end

# Formats
get '/events.ical' do
  content_type 'text/calendar'
  cal = settings.parser.to_ical_calendar(settings.parser.filter(params[:filter]))

  cal.to_ical
end

get '/events.atom' do
  content_type 'application/atom+xml'
  feed = settings.parser.to_atom(settings.parser.filter(params[:filter]))

  feed.to_s
end

get '/events.txt' do
  content_type 'text/plain'

  settings.parser.to_txt(settings.parser.filter(params[:filter]))
end

get '/events.json' do
  content_type 'application/json'
  json = settings.parser.to_json(settings.parser.filter(params[:filter]))

  json.to_s
end