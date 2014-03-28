# stdlib
require 'pathname'
require 'date'
require 'rss'
require 'json'
# gem
require 'icalendar'

# Parse dokuwiki table and return events in multiple formats
class Eventkalender
  class Parser

    attr_reader :events_table, :timestamp

    # Parsed content from dokuwiki page and returned Hash with events
    #
    # @return [array]
    def events
      # Get events table from web page scraper or from instance variable
      if @events_table.nil? || @timestamp - 20.minutes.ago < 0
        @events_table = Eventkalender::Scraper.scrape!
        @timestamp    = Time.now
      end

      # Events inside table are separated in rows
      event_rows = @events_table.search('./tr')

      # Ugly workaround for xpath problems.
      # This if clause is only needed for rspec and webmock.
      if event_rows.count == 0
        event_rows = @events_table.search('./*/tr')
      end

      # Iterate over all rows and create ical events for every event
      events = event_rows.map do |row|
        # Skip headlines
        next if row.search('./td').empty?

        to_event(row)
      end

      # Remove nil objects
      events.compact
    end

    # Converts string into event object
    #
    # @param [Nokogiri::XML::Element] table_row
    # @return [Event] event
    def to_event(table_row)
      # Search all cols in event row
      raw_event = table_row.search('./td')
      # Create new ical object
      event     = Eventkalender::Event.new

      # Add more information to ical object
      event.name        = raw_event[0].text       # Event name
      event.location    = raw_event[1].text       # Event location
      event.start_date  = Eventkalender::Parser.date(raw_event[2].text) # Start date
      event.end_date    = Eventkalender::Parser.date(raw_event[3].text) # End date plus one day to have last day also complete
      event.description = raw_event[5].text       # URL

      event
    end

    # Converts array with events into ical calendar
    #
    # @param [Array] events
    # @return [Icalendar::Calendar]
    def to_ical_calendar(events = self.events)
      # Create new ical calendar
      calendar = Icalendar::Calendar.new
      # Setting time zone
      calendar.timezone do
        timezone_id = 'Europe/Berlin'
      end

      # Add every object in array to new created calendar
      events.each{ |event| calendar.add( event.to_ical ) }

      calendar
    end

    # Converts events array to plain text
    #
    # @param [Array] events
    # @return [String] txt file
    def to_txt(events = self.events)
      # Create empty string
      txt = ''

      events.each do |event|
        # Add event to string
        txt << <<EOS
#{event.name} - #{event.location}
#{event.start_date.strftime('%d.%m.%Y')} - #{event.end_date.strftime('%d.%m.%Y')}


EOS
        end

      txt
    end

    # Create atom feed from given events array
    #
    # @param [Array] events
    # @return [RSS::Atom::Feed] feed
    def to_atom(events = self.events)
      RSS::Maker.make('atom') do |maker|
        maker.channel.author  = 'eventkalender'
        maker.channel.updated = Time.now.to_s
        maker.channel.about   = 'http://c3voc.de'
        maker.channel.title   = 'VOC Events'

        events.each { |event|
          maker.items.new_item do |item|
            item.title       = event.name
            item.id          = <<EOS
#{event.name.gsub(' ', '')}#{event.start_date}#{event.end_date}
EOS
            item.description = <<EOS
#{event.name} in #{event.location} vom #{event.start_date.strftime('%d.%m.%Y')} bis #{event.end_date.strftime('%d.%m.%Y')}.
EOS
            item.updated = Time.now.to_s
          end
        }
      end
    end

    # Create json stream from a give events array
    #
    # @param [Array] events
    # @return [JSON] json
    def to_json(events = self.events)
      hash = { voc_events: {} }

      events.each do |event|
        hash[:voc_events][event.name] = {}
        hash[:voc_events][event.name][:name] = event.name
        hash[:voc_events][event.name][:location] = event.location
        hash[:voc_events][event.name][:start_date] = event.start_date
        hash[:voc_events][event.name][:end_date] = event.end_date
        hash[:voc_events][event.name][:description] = event.description
      end

      JSON.generate(hash)
    end

    # Date converter, witch converts strings into valid date objects if possible
    #
    # @return [Date]
    # @param [String] date_string content looks like 2014-12-24
    def self.date(date_string)
      Date.parse(date_string)
    end

  end
end