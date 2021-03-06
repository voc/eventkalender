# frozen_string_literal: true

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
  class Conference < Event
    attr_reader   :start_date, :end_date, :streaming, :buildup, :teardown
    attr_accessor :wiki_path, :planing_status, :name, :location, :description,
                  :short_name

    # Create new event object
    #
    # @param options [Hash] to create an event with.
    # @option options [String] :name The event name
    # @option options [String] :location The event location
    # @option options [String] :start_date Events start date
    # @option options [String] :end_date Events end date
    # @option options [String] :description The event description
    # @option options [String] :wiki_path The event path in c3voc wiki
    # @option options [String] :short_name The event short name
    # @option options [String] :streaming Planed event streaming status
    # @option options [String] :planing_status Planed event status
    # @option cases   [Array] :cases Used onsite
    # @option teardown [Date] teardown of the Event
    # @option buildup [Date] :buildup of the Event
    def initialize(options = {})
      super(options)
      # optional
      @description    = options[:description]
      @wiki_path      = options[:wiki_path]
      @short_name     = options[:short_name]
      self.streaming  = options[:streaming]
      @planing_status = options[:planing_status]
      self.cases      = options[:cases]
      @buildup        = options[:buildup]
      @teardown       = options[:teardown]
    end

    # Setter for buildup.
    #
    # @example Setting events buildup date.
    #   event.buildup = "2014-05-23" #=> "2014-05-23"
    #
    # @param date [String] buildup date of a event to set
    # @return [Date] converted and set buildup date
    def buildup=(date)
      @buildup = check_date_input(date)
    end

    # Setter for buildup.
    #
    # @example Setting events teardown date.
    #   event.buildup = "2014-05-23" #=> "2014-05-23"
    #
    # @param date [String] teardown date of a event to set
    # @return [Date] converted and set teardown date
    def teardown=(date)
      @teardown = check_date_input(date)
    end

    # Convert event to ical.
    #
    # @example Convert event to ical object.
    #   event.to_ical #=>  #<Icalendar::Event:0x00000002f02ee8 @name="VEVENT" … >
    #
    # @return [Icalendar::Event] converted ical event
    def to_ical
      Icalendar::Event.new.tap do |e|
        e.summary     = @name
        e.location    = @location
        e.dtstart     = Icalendar::Values::Date.new(@start_date.to_date)
        e.dtend       = Icalendar::Values::Date.new(@end_date.to_date + 1)
        e.description = @description
      end
    end

    # Setter for streaming.
    #
    # @example Setting events end date.
    #   event.streaming = "yes" #=> true
    #
    # @param status [String] streaming of an event to set
    # @return [Boolean] converted and set streaming status
    def streaming=(status)
      @streaming = Eventkalender::Parser.detect_streaming(status)
    end

    # Setter for cases
    #
    # @param cases_string [string] from doku wiki
    # @return [Array] room cases
    def cases=(cases_string)
      @cases = if cases_string.nil?
                 []
               else
                 cases_string.delete(' ').split(',')
               end
    end

    # Getter for cases
    #
    # @return [Array] room cases
    def cases
      @cases
    end
  end
end
