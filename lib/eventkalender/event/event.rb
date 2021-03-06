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
  class Event
    attr_reader   :start_date, :end_date
    attr_accessor :name, :location

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
    def initialize(options = {})
      @name           = options[:name]
      @location       = options[:location]
      self.start_date = options[:start_date]
      self.end_date   = options[:end_date]
    end

    # Setter for start_date.
    #
    # @example Setting events start date.
    #   event.start_date = "2014-05-23" #=> "2014-05-23"
    #
    # @param date [String] start date of a event to set
    # @return [Date] converted and set start date
    def start_date=(date)
      @start_date = check_date_input(date)
    end

    # Setter for end_date.
    #
    # @example Setting events end date.
    #   event.end_date = "2014-05-23" #=> "2014-05-23"
    #
    # @param date [String] end date of a event to set
    # @return [Date] converted and set end date
    def end_date=(date)
      @end_date = check_date_input(date)
    end

    # Check whether an event is already done or not.
    #
    # @return [Boolean] true or false
    def past?
      end_date < Date.today
    end

    # Check whether an event is upcoming or not.
    #
    # @return [Boolean] true or false
    def upcoming?
      start_date >= Date.today
    end

    # Check whether an event is now or not.
    #
    # @return [Boolean] true or false
    def now?
      start_date <= Date.today && end_date >= Date.today
    end

    # Return current planing status of the event.
    #
    # @return [Boolean] status
    def idea?
      @planing_status =~ /[Ii]dea/ ? true : false
    end

    protected

    # Convert dates into real date object
    #
    # @param date [String] date which needs to converted
    #
    # @return [Date] a valid date object if everything is fine
    # @return [nil] if input was not a valid date
    def check_date_input(date)
      Eventkalender::Parser.date(date)
    end
  end
end
