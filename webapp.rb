require 'sinatra'
require 'sinatra/namespace'
require 'haml'

require_relative 'lib/eventkalender'

set :views,  File.dirname(__FILE__) + '/views'
set :parser, Eventkalender::Parser.new
set :public_folder, File.dirname(__FILE__) + '/views/public'

set :sub_path, ""

# HTML pages
namespace "#{settings.sub_path}" do
  get '/' do
    @events = settings.parser.events[:conferences].events.map do |event|
      # orange: #FF8C00
      <<-EOF
  {
    title: "#{event.name}",
    start: "#{event.start_date}",
    end: "#{event.end_date + 1}",
    url: "#{event.description}",
    color: '#28c3ab'
  },
  EOF
    end << settings.parser.events[:meetings].events.map do |event|
      # orange: #FF8C00
      <<-EOF
  {
    title: "#{event.name}",
    start: "#{event.start_date}",
    end: "#{event.end_date}",
    url: "#{event.description}",
    color: 'orange'
  },
  EOF
    end

    if params[:gotodate]
      @gotodate = @params[:gotodate]
    else
      @gotodate = Date.today
    end

    haml :index
  end

  get '/events.html' do
    @events = filter(filter_params,
                     settings.parser.events[meetings_or_conferences].events)

    haml :events
  end

  # Formats
  get '/events.ical' do
    content_type 'text/calendar'

    events = filter

    cal = settings.parser.to_ical_calendar(events)
    cal.to_ical
  end

  get '/events.atom' do
    content_type 'application/atom+xml'

    events = filter

    feed = settings.parser.events[meetings_or_conferences].to_atom(events)
    feed.to_s
  end

  get '/events.txt' do
    content_type 'text/plain'

    events = filter
    settings.parser.events[meetings_or_conferences].to_txt(events)
  end

  get '/events.json' do
    content_type 'application/json'

    events = filter

    json = settings.parser.events[meetings_or_conferences].to_json(events)
    json.to_s
  end
end




# helper function
def filter_params
  { general: params[:filter], streaming: params[:streaming], idea: params[:idea] }
end

def meetings_or_conferences
  params[:meetings].nil? ? :conferences : :meetings
end

# Filter for specific keywords or parameter.
# @todo
#   Filtering for time and streaming is ugly implemented.
#   Looping and checking multiple times should be removed, soon.
#
# @example Filter for past events
#   parser.filter({ general: past, streaming: true }) #=> [#<Eventkalender::Conference:0x00000002ab5b88 … >, …]
#
# @param filter [Hash] used for filtering
# @option filter [String] :general Normal filter option
# @option filter [String] :streaming Streaming status
# @param events [Array<Event>, #events] witch schould be filtered
#
# @return [Array] with filtered events
def filter(filter = filter_params,
           events = settings.parser.events[meetings_or_conferences].events)
  filtered_events = case filter[:general]
  # All past events
  when /past/
    events.find_all { |event| event.past? }
  # All upcoming events
  when /upcoming/
    events.find_all { |event| event.upcoming? }
  # Currently running events
  when /now|today/
    events.find_all { |event| event.now? }
  # Match a year
  when /\d{4}/
    events.find_all { |event| event.start_date.year == filter[:general].to_i }
  # Return all events if no filter is set
  when /meeting/
    events.find_all { |event| event.class == Eventkalender::Meeting }
  when /conference/
      events.find_all { |event| event.class == Eventkalender::Conference }
  # Return all events if no filter is set
  else
    events
  end

  # filter for idea events
  # default: remove idea events
  if filter[:idea] == 'true'
    filtered_events
  else
    filtered_events = remove_idea_events(filtered_events)
  end

  filter_streaming(filter[:streaming], filtered_events)
end


# Filter for events with streaming status.
#
# @example Filter  for events with streaming
#   parser.filter_streaming('true') #=>  [#<Eventkalender::Conference:0x000000036b6810 … @streaming=true>, …]
#
# @param filter [String] witch is used for filtering
# @param events [Array<Event>, #events] to filter
#
# @return [Array] events witch match the given filter
def filter_streaming(filter, events)
  case filter
  when /true|yes/
    events.find_all { |event| event.streaming }
  when /false|no/
    events.find_all { |event| event.streaming == false }
  when /undefined|nil|null/
    events.find_all { |e| e.streaming == nil }
  else
    events
  end
end

# Remove events with status idea
#
# @param events [Array<Event>, #events] to filter
# @return [Array] events with status idea
def remove_idea_events(events)
  events.delete_if { |event| event.idea? }
end
