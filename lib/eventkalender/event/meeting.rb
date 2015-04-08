class Eventkalender
  # Represents a voc event.
  #
  # @!attribute [rw] start_date
  #   @param date [String] witch represents start date of the event
  #   @return [Date] event start date
  # @!attribute [rw] end_date
  #   @param date [String] witch represents end date of the event
  #   @return [Date] event end date
  # @!attribute [rw] name
  #   @return [String] event name
  # @!attribute [rw] location
  #   @return [String] event location
  # @!attribute [rw] description
  #   @return [String] event description, in general it's used for event url
  # @!attribute [rw] short_name
  #   @return [String] event synonym
  # @!attribute [rw] wiki_path
  #   @return [String] event path in voc wiki
  # @!attribute [rw] streaming
  #   @return [String] event streaming status
  # @!attribute [rw] planing_status
  #   @return [String] event planing status
  class Meeting < Event

    attr_reader   :start_date, :end_date
    attr_accessor :tags, :type, :link, :location, :description, :name

    # Create new event object
    #
    # @param options [Hash] to create an event with.
    # @option options [String] :name The event name
    # @option options [String] :location The event location
    # @option options [String] :start_date Events start date
    # @option options [String] :end_date Events end date
    # @option options [String] :description The event description
    # @option options [String] :pad_url The mumble pad url
    # @option options [String] :planing_status Planed event status
    # @option options [Boolean] :mumble Planed event status
    def initialize(options = {})
      super(options)
      # optional
      @type        = options[:type]
      @link        = options[:pad_url]
      @tags        = convert_tags(options[:tags])
      @link        = options[:link]
    end

    # Convert event to ical.
    #
    # @example Convert event to ical object.
    #   event.to_ical #=>  #<Icalendar::Event:0x00000002f02ee8 @name="VEVENT" … >
    #
    # @return [Icalendar::Event] converted ical event
    def to_ical
      Icalendar::Event.new.tap { |e|
        e.summary     = @name
        e.location    = @location
        e.dtstart     = @start_date
        e.dtend       = @end_date
        e.description = @link
      }
    end

    def description
      "#{@link}"
    end

    # Convert given string to an array with tags.
    #
    # @param string [String]
    # @return [Array] tags
    def convert_tags(string)
      if string.nil?
        []
      else
        tags = string.split(',')
        tags.map(&:strip)
      end
    end

    # Is that meeting a mumble meeting?
    #
    # @return [Boolean]
    def mumble?
      @type =~ /[Mm]umble/ ? true : false
    end

    # Setter for tags.
    #
    # @param string [String] with tags comma seperated
    # @return [Array] with tags
    def tags=(string)
      @tags = convert_tags(string)
    end
  end
end
