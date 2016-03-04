# encoding: utf-8

class Eventkalender
  class Parser::Meetings < Eventkalender::Parser

    attr_accessor :event_table

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
               "#{event.start_date.strftime('%d.%m.%Y %H:%M')} Uhr"\
               " - #{event.end_date.strftime('%d.%m.%Y %H:%M')} Uhr"

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
      # return nil if no dates are set
      return nil if raw_event[3].text.empty? || raw_event[4].text.empty?
      begin
        start_date = DateTime.parse("#{self.class.date(raw_event[3].text)} #{raw_event[5].text}") # Start date time
        end_date = DateTime.parse("#{self.class.date(raw_event[4].text)} #{raw_event[6].text}") # End date time
      rescue
        return nil
      end
      # Create new ical object and return it
      Eventkalender::Meeting.new.tap { |e|
        # Add more information to ical object.
        e.name           = raw_event[0].text       # Event name
        e.type           = raw_event[1].text       # URL
        e.location       = raw_event[2].text       # Event location
        e.start_date     = start_date
        e.end_date       = start_date
        e.link           = raw_event[7].text       # URL
        e.tags           = raw_event[8].text       # Tags
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
        maker.channel.link    = 'http://c3voc.de/eventkalender/events.atom?meetrings=✓'
        maker.channel.links.first.rel  = 'self'
        maker.channel.links.first.type = 'application/atom+xml'

        maker.channel.title   = 'VOC Meetings'

        events.each { |event|
          maker.items.new_item do |item|
            item.updated     = Time.now.to_s
            item.title       = event.name
            item.id          = "tag:c3voc.de,#{event.start_date.strftime('%Y-%m-%d_%H:%M')}:#{event.end_date.strftime('%Y-%m-%d_%H:%M')}"
            item.description = "#{event.name} in #{event.location} "\
                               "vom #{event.start_date.strftime('%d.%m.%Y %H:%M')} Uhr "\
                               "bis #{event.end_date.strftime('%d.%m.%Y %H:%M')} Uhr."
            item.link        = 'http://c3voc.de/eventkalender'
          end
        }
      end
    end

    # Create json stream from a give events array.
    #
    # @example Convert given events to json
    #   parser.to_json #=> ""{\n  \"voc_meetings\": {\n    …"
    #
    # @param events [Array<Event>, #events] to convert to json
    # @return [JSON] events in json
    def to_json(events = self.events)
      hash = { voc_meetings: {}, voc_meetings_count: {} }

      events.each do |event|
        hash[:voc_meetings][event.name] = {}
        hash[:voc_meetings][event.name][:name]           = event.name
        hash[:voc_meetings][event.name][:location]       = event.location
        hash[:voc_meetings][event.name][:start_date]     = event.start_date
        hash[:voc_meetings][event.name][:end_date]       = event.end_date
        hash[:voc_meetings][event.name][:description]    = event.description
        hash[:voc_meetings][event.name][:tags]           = event.tags
      end

      hash[:voc_meetings_count][:all]                    = events.count

      JSON.pretty_generate(hash)
    end

    def description
      "#{@link}"
    end
  end
end
