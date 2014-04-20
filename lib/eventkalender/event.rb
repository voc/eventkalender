class Eventkalender
  class Event

    attr_reader   :start_date, :end_date
    attr_accessor :name, :location, :description

    # Create new event object
    #
    # @param [Hash] options
    def initialize(options = {})
      @name        = options[:name]
      @location    = options[:location]
      @start_date  = check_date_input(options[:start_date])
      @end_date    = check_date_input(options[:end_date])
      @description = options[:description]
    end

    # Setter for start_date
    #
    # @param [String] date
    # @return [Date] date
    def start_date=(date)
      @start_date = check_date_input(date)
    end

    # Setter for end_date
    #
    # @param [String] date
    # @return [Date] event
    def end_date=(date)
      @end_date = check_date_input(date)
    end

    # Convert event to ical
    #
    # @return [Icalendar::Event] event
    def to_ical
      # return ical event
      Icalendar::Event.new.tap { |e|
        e.summary     = @name
        e.location    = @location
        e.start       = @start_date
        e.end         = @end_date + 1 # TODO: DateTime would maybe a better choice
        e.description = @description
      }
    end

    protected

    # Convert (string) dates into date object
    #
    # @param [String] date
    # @return [Date] date or nil
    def check_date_input(date)
      Eventkalender::Parser.date(date)
    end

  end
end