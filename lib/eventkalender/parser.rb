# stdlib
require 'pathname'
require 'date'
require 'rss'
require 'json'
# gem
require 'icalendar'


class Eventkalender
  # Parser class can be used to parse dokuwiki table and return events in multiple formats.
  #
  # @example Create parser to parse voc wiki events page.
  #   parser = Eventkalender::Parser.new
  #   parser.events #=>  [#<Eventkalender::Event:0x00000002a49f78 … ]
  #
  # @example Convert date String into Date object.
  #   Eventkalender::Parser.date('23-12-2014') #=> #<Date: 2014-12-23 ((2457015j,0s,0n),+0s,2299161j)>
  #
  # @!attribute [r] events_table
  #   @return [Nokogiri::XML::Element] Contains scraped event table.
  # @!attribute [r] timestamp
  #   @return [Time] Last scraping time.
  class Parser

    attr_reader :events_table, :timestamp

    # Parsed content from dokuwiki page and returned Hash with events.
    #
    # @example Scrape events
    #   parser.events(true) #=> [#<Eventkalender::Event:0x0000000332e300 @name=…, …]
    #
    # @param force_scraping [Boolean] to force scraping
    # @return [Array] scraped events
    def events(force_scraping = false)
      # Get events table from web page scraper or from instance variable
      if @events_table.nil? || @timestamp - 20.minutes.ago < 0 || force_scraping
        @events_table = Eventkalender::Scraper.scrape!
        @timestamp    = Time.now
      end

      # Events inside table are separated in rows.
      event_rows = @events_table.search('./tr')

      # HACK: Ugly workaround for unknown xpath matching problems.
      #       If clause is only needed for rspec and webmock.
      if event_rows.count == 0
        event_rows = @events_table.search('./*/tr')
      end

      # Iterate over all rows and create ical events for every event.
      events = event_rows.map do |row|
        # Skip headlines
        next if row.search('./td').empty?

        to_event(row)
      end

      # Remove nil objects
      events.compact
    end

    # Converts string into event object.
    #
    # @param table_row [Nokogiri::XML::Element] that should be converted to an event
    # @return [Event] event
    def to_event(table_row)
      # Search all cols in event row.
      raw_event = table_row.search('./td')
      # Create new ical object and return it
      Eventkalender::Event.new.tap { |e|
        # Add more information to ical object.
        e.name        = raw_event[0].text       # Event name
        e.location    = raw_event[1].text       # Event location
        e.start_date  = self.class.date(raw_event[2].text) # Start date
        e.end_date    = self.class.date(raw_event[3].text) # End date + 1 day to have last day also complete
        e.description = raw_event[5].text       # URL
        e.streaming   = raw_event[7].text       # Is streaming planed?

        url_path = raw_event[0].xpath('./a[@href]')[0]['href']
        e.short_name  = /^.*\/(.*)$/.match(url_path)[1]
        e.wiki_path   = url_path
      }
    end

    # Converts array with events into ical calendar.
    #
    # @param events [Array<Event>, #events] to convert to an ical calender
    # @return [Icalendar::Calendar] converted events
    def to_ical_calendar(events = self.events)
      # Create new ical calendar
      calendar = Icalendar::Calendar.new
      # Setting time zone
      calendar.timezone { |t| t.tzid = 'Europe/Berlin' }
      # Add every object in array to new created calendar
      events.each { |event| calendar.add(event.to_ical) }

      calendar
    end

    # Converts events array to plain text.
    #
    # @example Convert events to text.
    #   parser.to_txt(events) #=> "Hack*n*Play2 - Freiburg21.02.2014 - 23.02.2014"
    #
    # @param events [Array<Event>, #events] to convert to plain text
    # @return [String] txt file
    def to_txt(events = self.events)
      # Create empty string
      txt = ''

      events.each do |event|
        # Add event to string
        txt << "#{event.name} - #{event.location}\n"\
               "#{event.start_date.strftime('%d.%m.%Y')} - #{event.end_date.strftime('%d.%m.%Y')}"

        # Adding two empty lines when current event is not the last one
        unless events.last.name == event.name
          txt << "\n\n"
        end
      end

      txt
    end

    # Create atom feed from given events array.
    #
    # @example Generate rss feed for given events.
    #   parser.events #=>  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\" …"
    #
    # @param events [Array<Event>, #events] to convert to an atom feed
    # @return [RSS::Atom::Feed] created rss feed
    def to_atom(events = self.events)
      RSS::Maker.make('atom') do |maker|
        maker.channel.author  = 'eventkalender'
        maker.channel.updated = Time.now.to_s
        maker.channel.about   = 'http://c3voc.de/'
        maker.channel.link    = 'http://c3voc.de/eventkalender/events.atom'
        maker.channel.links.first.rel  = 'self'
        maker.channel.links.first.type = 'application/atom+xml'

        maker.channel.title   = 'VOC Events'

        events.each { |event|
          maker.items.new_item do |item|
            item.updated     = Time.now.to_s
            item.title       = event.name
            item.id          = "tag:c3voc.de,#{event.start_date.strftime('%Y-%m-%d')}:#{events.index(event) + 1}"
            item.description = "#{event.name} in #{event.location} "\
                               "vom #{event.start_date.strftime('%d.%m.%Y')} "\
                               "bis #{event.end_date.strftime('%d.%m.%Y')}."
            item.link        = 'http://c3voc.de/eventkalender'
          end
        }
      end
    end

    # Create json stream from a give events array.
    #
    # @example Convert given events to json
    #   parser.to_json #=> ""{\n  \"voc_events\": {\n    …"
    #
    # @param events [Array<Event>, #events] to convert to json
    # @return [JSON] events in json
    def to_json(events = self.events)
      hash = { voc_events: {}, voc_events_count: {} }

      events.each do |event|
        hash[:voc_events][event.name] = {}
        hash[:voc_events][event.name][:name]          = event.name
        hash[:voc_events][event.name][:short_name]    = event.short_name
        hash[:voc_events][event.name][:location]      = event.location
        hash[:voc_events][event.name][:start_date]    = event.start_date
        hash[:voc_events][event.name][:end_date]      = event.end_date
        hash[:voc_events][event.name][:description]   = event.description
        hash[:voc_events][event.name][:voc_wiki_path] = event.wiki_path
        hash[:voc_events][event.name][:streaming]     = event.streaming
      end

      # Adding statistical data
      hash[:voc_events_count][:all]                 = events.count
      hash[:voc_events_count][:with_streaming]      = filter_streaming('true', events).count
      hash[:voc_events_count][:without_streaming]   = filter_streaming('false', events).count
      hash[:voc_events_count][:undefined_streaming] = filter_streaming('nil', events).count

      JSON.pretty_generate(hash)
    end

    # Date converter, witch converts strings into valid date objects if possible.
    #
    # @example Parse date string
    #   Eventkalender::parser.date('2014-12-24') #=> #<Date: 2014-12-24 ((2457016j,0s,0n),+0s,2299161j)>
    #
    # @raise
    #   [ArgumentError] if invalid date is given and parsing failed
    # @param date [String] content looks like
    # @return [Date, nil] created date object or nil if creation failed
    def self.date(date)
      # Catching type class of input value
      case date
      when Date
        date
      when String
        Date.parse(date)
      else
        nil
      end
    end

    # Filter for specific keywords or parameter.
    # @todo
    #   Filtering for time and streaming is ugly implemented.
    #   Looping and checking multiple times should be removed, soon.
    #
    # @example Filter for past events
    #   parser.filter({ general: past, streaming: true }) #=> [#<Eventkalender::Event:0x00000002ab5b88 … >, …]
    #
    # @param filter [Hash] used for filtering
    # @option filter [String] :general Normal filter option
    # @option filter [String] :streaming Streaming status
    # @param events [Array<Event>, #events] witch schould be filtered
    #
    # @return [Array] with filtered events
    def filter(filter, events = self.events)
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
      else
        events
      end

      filter_streaming(filter[:streaming], filtered_events)
    end

    # Filter for events with streaming status.
    #
    # @example Filter  for events with streaming
    #   parser.filter_streaming('true') #=>  [#<Eventkalender::Event:0x000000036b6810 … @streaming=true>, …]
    #
    # @param filter [String] witch is used for filtering
    # @param events [Array<Event>, #events] to filter
    #
    # @return [Array] events witch match the given filter
    def filter_streaming(filter, events = self.events)
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

    # Detect if there is live streaming planed.
    #
    # @example
    #   parser.detect_streaming('yes') #=> true
    #
    # @param string [String] to check
    # @return [Boolean, nil] streaming status true or false or not defined
    def detect_streaming(string)

    end

  end
end
