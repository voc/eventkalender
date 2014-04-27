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
    # @param [Boolean] force_scraping
    # @return [array]
    def events(force_scraping = false)
      # Get events table from web page scraper or from instance variable
      if @events_table.nil? || @timestamp - 20.minutes.ago < 0 || force_scraping
        @events_table = Eventkalender::Scraper.scrape!
        @timestamp    = Time.now
      end

      # Events inside table are separated in rows
      event_rows = @events_table.search('./tr')

      # HACK: Ugly workaround for unknown xpath matching problems.
      #       If clause is only needed for rspec and webmock.
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
      # Create new ical object and return it
      Eventkalender::Event.new.tap { |e|
        # Add more information to ical object
        e.name        = raw_event[0].text       # Event name
        e.location    = raw_event[1].text       # Event location
        e.start_date  = self.class.date(raw_event[2].text) # Start date
        e.end_date    = self.class.date(raw_event[3].text) # End date + 1 day to have last day also complete
        e.description = raw_event[5].text       # URL
        e.streaming   = detect_streaming(raw_event[7].text) # Is streaming planed?

        url_path = raw_event[0].xpath('./a[@href]')[0]['href']
        e.short_name  = /^.*\/(.*)$/.match(url_path)[1]
        e.wiki_path   = url_path
      }
    end

    # Converts array with events into ical calendar
    #
    # @param [Array] events
    # @return [Icalendar::Calendar]
    def to_ical_calendar(events = self.events)
      # Create new ical calendar
      calendar = Icalendar::Calendar.new
      # Setting time zone
      calendar.timezone { timezone_id = 'Europe/Berlin' }
      # Add every object in array to new created calendar
      events.each { |event| calendar.add(event.to_ical) }

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
        hash[:voc_events][event.name][:name]          = event.name
        hash[:voc_events][event.name][:short_name]    = event.short_name
        hash[:voc_events][event.name][:location]      = event.location
        hash[:voc_events][event.name][:start_date]    = event.start_date
        hash[:voc_events][event.name][:end_date]      = event.end_date
        hash[:voc_events][event.name][:description]   = event.description
        hash[:voc_events][event.name][:voc_wiki_path] = event.wiki_path
        hash[:voc_events][event.name][:streaming]     = event.streaming
      end

      JSON.pretty_generate(hash)
    end

    # Date converter, witch converts strings into valid date objects if possible
    #
    # @param [String] date content looks like 2014-12-24
    # @return [Date]
    def self.date(date)
      # Catching type class of input value
      case date
      when Date
        date
      when String
        # Raised ArgumentError: invalid date error if parsing failed
        Date.parse(date)
      else
        nil
      end
    end

    # Filter for specific keywords or parameter
    #
    # @param [String, Array] filter, events
    # @return [Array] events
    def filter(filter, events = self.events)
      filtered_events = []

      case filter
      # All past events
      when /past/
        events.each do |event|
          if event.end_date <= Date.today
            filtered_events << event
          end
        end
      # All upcoming events
      when /upcoming/
        events.each do |event|
          if event.end_date >= Date.today
            filtered_events << event
          end
        end
      # Currently running events
      when /now|today/
        events.each do |event|
          if event.start_date <= Date.today && event.end_date >= Date.today
            filtered_events << event
          end
        end
      # Match a year
      when /\d{4}/
        events.each do |event|
          if event.start_date.year == filter.to_i
            filtered_events << event
          end
        end
      # Return all events if no filter is set
      else
        filtered_events = events
      end

      filtered_events
    end

    # Detect if there is live streaming planed
    #
    # @param [String] string
    # @return [Boolean]
    def detect_streaming(string)
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
