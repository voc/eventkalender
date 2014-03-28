require 'sinatra'
require 'haml'
require_relative 'lib/eventkalender'


set :parser, Eventkalender::Parser.new

# HTML pages
get '/' do
  haml :index  # template: ↓
end

get '/events.html' do
  haml :events # template: ↓
end

# Formats
get '/events.ical' do
  content_type 'text/calendar'
  cal = settings.parser.to_ical_calendar

  cal.to_ical
end

get '/events.atom' do
  content_type 'application/atom+xml'
  feed = settings.parser.to_atom

  feed.to_s
end

get '/events.txt' do
  content_type 'text/plain'

  settings.parser.to_txt
end

get '/events.json' do
  content_type 'application/json'
  json = settings.parser.to_json

  json.to_s
end


__END__

@@ layout
!!!5
%html
  %head
    %title c3voc events
    %link{ :href => "/events.atom", :rel => "alternate", :title => "Atom - VOC events", :type => "application/atom+xml" }
  %body
    = yield

@@ index
%h1 c3voc events
%ul
  - %w{ical atom json txt}.each do |format|
    %li
      %a{ href: "/events.#{format}" }= format