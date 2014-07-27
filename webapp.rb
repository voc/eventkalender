require 'sinatra'
require 'haml'
require_relative 'lib/eventkalender'

set :views,  File.dirname(__FILE__) + '/views'
set :parser, Eventkalender::Parser.new
set :public_folder, File.dirname(__FILE__) + '/views/public'

# HTML pages
get '/' do
  @events = settings.parser.filter(filter_params).map do |event|
    <<-EOF
{
  title: "#{event.name}",
  start: "#{event.start_date}",
  end: "#{event.end_date + 1}",
  url: "#{event.description}"
},
EOF
  end

  haml :index
end

get '/events.html' do
  haml :events
end

# Formats
get '/events.ical' do
  content_type 'text/calendar'

  cal = settings.parser.to_ical_calendar(settings.parser.filter(filter_params))
  cal.to_ical
end

get '/events.atom' do
  content_type 'application/atom+xml'

  feed = settings.parser.to_atom(settings.parser.filter(filter_params))
  feed.to_s
end

get '/events.txt' do
  content_type 'text/plain'

  settings.parser.to_txt(settings.parser.filter(filter_params))
end

get '/events.json' do
  content_type 'application/json'

  json = settings.parser.to_json(settings.parser.filter(filter_params))
  json.to_s
end

# helper function
def filter_params
  { general: params[:filter], streaming: params[:streaming], idea: params[:idea] }
end
