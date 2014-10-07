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
  class Mumble < Event
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
    def initialize(options = {})
      super(options)
      # optional
      @pad_url        = options[:wiki_path]
      @planing_status = options[:planing_status]
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
        e.dtstart     = Icalendar::Values::Date.new(@start_date.to_date)
        e.dtend       = Icalendar::Values::Date.new(@end_date.to_date + 1)
        e.description = @description
      }
    end

  end
end
