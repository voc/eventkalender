class Eventkalender
  class Event

    attr_reader   :start_date, :end_date
    attr_accessor :name, :location, :description

    # Create new event object
    #
    # @param [Hash] options
    def initialize(options = {})
      @name       = options[:name]
      @location   = options[:location]
      @start_date = check_date_input(options[:start_date])
      @end_date   = check_date_input(options[:end_date])
      @summary    = options[:summary]
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
      event = Icalendar::Event.new

      event.summary     = @name
      event.location    = @location
      event.start       = @start_date
      event.end         = @end_date + 1 # TODO: DateTime would maybe a better choice
      event.description = @description

      event
    end

    protected

    # Convert (string) dates into date object
    #
    # @param [String] date
    # @return [Date] date or nil
    def check_date_input(date)
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

  end
end