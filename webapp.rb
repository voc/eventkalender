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
  filter = { general: params[:filter], streaming: params[:streaming] }
  cal = settings.parser.to_ical_calendar(settings.parser.filter(filter))

  cal.to_ical
end

get '/events.atom' do
  content_type 'application/atom+xml'

  filter = { general: params[:filter], streaming: params[:streaming] }
  feed = settings.parser.to_atom(settings.parser.filter(filter))

  feed.to_s
end

get '/events.txt' do
  content_type 'text/plain'

  filter = { general: params[:filter], streaming: params[:streaming] }
  settings.parser.to_txt(settings.parser.filter(filter))
end

get '/events.json' do
  content_type 'application/json'

  filter = { general: params[:filter], streaming: params[:streaming] }
  json = settings.parser.to_json(settings.parser.filter(filter))

  json.to_s
end