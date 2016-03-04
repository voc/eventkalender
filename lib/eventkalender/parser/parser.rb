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
  #   parser.events #=>  [#<Eventkalender::Conference:0x00000002a49f78 … ]
  #
  # @example Convert date String into Date object.
  #   Eventkalender::Parser.date('23-12-2014') #=> #<Date: 2014-12-23 ((2457015j,0s,0n),+0s,2299161j)>
  #
  # @!attribute [r] events_table
  #   @return [Nokogiri::XML::Element] Contains scraped event table.
  # @!attribute [r] timestamp
  #   @return [Time] Last scraping time.
  class Parser

    attr_reader :events_tables, :timestamp


    def parse(table = @event_table)
      found_events = []

      # Events inside table are separated in rows.
      event_rows = table.search('./tr')

      # HACK: Ugly workaround for unknown xpath matching problems.
      #       If clause is only needed for rspec and webmock.
      if event_rows.count == 0
        event_rows = table.search('./*/tr')
      end

      # Iterate over all rows and create ical events for every event.
      events = event_rows.map do |row|
        # Skip headlines
        next if row.search('./td').empty?

      	event = to_event(row)
      	if event.nil?
          next
      	else
          found_events << event
        end
      end

      # Remove nil objects
      events.compact

      found_events
    end

    # Parsed content from dokuwiki page and returned Hash with events.
    #
    # @example Scrape events
    #   parser.events(true) #=> [#<Eventkalender::Conference:0x0000000332e300 @name=…, …]
    #
    # @param force_scraping [Boolean] to force scraping
    # @return [Array] scraped events
    def events(force_scraping = false)
      # Get events table from web page scraper or from instance variable
      if @events_tables.nil? || @timestamp - 20.minutes.ago < 0 || force_scraping
        @events_tables = Eventkalender::Scraper.scrape!
        @timestamp     = Time.now
      end

      events = {}
      @events_tables.each do |e_table|
        case e_table[:type]
        when :meetings
          events[:meetings]    = Eventkalender::Parser::Meetings.new(e_table[:table])
        when :conferences
          events[:conferences] = Eventkalender::Parser::Conferences.new(e_table[:table])
        end
      end

      events
    end

    # Converts array with events into ical calendar.
    #
    # @param events [Array<Event>, #events] to convert to an ical calender
    # @return [Icalendar::Calendar] converted events
    def to_ical_calendar(events)
      # Create new ical calendar
      calendar = Icalendar::Calendar.new
      # Setting time zone
      calendar.timezone { |t| t.tzid = 'Europe/Berlin' }
      # Add every object in array to new created calendar
      events.each { |event| calendar.add_event(event.to_ical) }

      calendar
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
        begin
          Date.parse(date)
        rescue
          nil
        end
      else
        nil
      end
    end

    # Detect if there is live streaming planed.
    #
    # @example
    #   Eventkalender.parser.detect_streaming('yes') #=> true
    #
    # @param string [String] to check
    # @return [Boolean, nil] streaming status true or false or not defined
    def self.detect_streaming(string)
      case string
        when /[Jj]a|[Yy]es/
          true
        when /[Nn]ein|[Nn]o/
          false
        else
          nil
      end
    end
  end
end
