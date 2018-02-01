class Eventkalender
  class Parser::Conferences < Eventkalender::Parser

    def initialize(event_table)
      @event_table = event_table
      parse(event_table)
    end

    def events(events = self.parse)
      events
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

    # Converts string into event object.
    #
    # @param table_row [Nokogiri::XML::Element] that should be converted to an event
    # @return [Event] event
    def to_event(table_row)
      # Search all cols in event row.
      raw_event = table_row.search('./td')
      # Return nil if dates are not set
      return nil if raw_event[3].text.empty? || raw_event[2].text.empty?
      start_date = self.class.date(raw_event[2].text) # Start date
      end_date = self.class.date(raw_event[3].text) # End date
      buildup = self.class.date(raw_event[9].text)
      teardown = self.class.date(raw_event[10].text)
      return nil if start_date.nil? || end_date.nil?
      # Create new ical object and return it
      Eventkalender::Conference.new.tap { |e|
        # Add more information to ical object.
        e.name           = raw_event[0].text       # Event name
        e.location       = raw_event[1].text       # Event location
        e.start_date     = start_date
        e.end_date       = end_date
        e.description    = raw_event[5].text       # URL
        e.streaming      = raw_event[7].text       # Is streaming planed?
        e.planing_status = raw_event[8].text       # Event planing status
        e.buildup        = buildup
        e.teardown       = teardown
        e.cases          = raw_event[11].text


        url_path = raw_event[0].xpath('./a[@href]')[0]['href']
        e.short_name  = /^.*\/(.*)$/.match(url_path)[1]
        e.wiki_path   = url_path
      }
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
        hash[:voc_events][event.name][:name]           = event.name
        hash[:voc_events][event.name][:short_name]     = event.short_name
        hash[:voc_events][event.name][:location]       = event.location
        hash[:voc_events][event.name][:start_date]     = event.start_date
        hash[:voc_events][event.name][:end_date]       = event.end_date
        hash[:voc_events][event.name][:description]    = event.description
        hash[:voc_events][event.name][:voc_wiki_path]  = event.wiki_path
        hash[:voc_events][event.name][:streaming]      = event.streaming
        hash[:voc_events][event.name][:planing_status] = event.planing_status
        hash[:voc_events][event.name][:cases]          = event.cases
        hash[:voc_events][event.name][:buildup]        = event.buildup
        hash[:voc_events][event.name][:teardown]       = event.teardown
      end

      # Adding statistical data
      hash[:voc_events_count][:all]                 = events.count
      hash[:voc_events_count][:with_streaming]      = filter_streaming('true', events).count
      hash[:voc_events_count][:without_streaming]   = filter_streaming('false', events).count
      hash[:voc_events_count][:undefined_streaming] = filter_streaming('nil', events).count

      JSON.pretty_generate(hash)
    end
  end
end
