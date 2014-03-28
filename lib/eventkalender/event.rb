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
      @start_date = check_date_input(options[:start_date]) unless options[:start_date].nil?
      @end_date   = check_date_input(options[:end_date])   unless options[:end_date].nil?
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

    # Convert string dates into date object
    #
    # @param [String] date
    # @return [Date] date
    def check_date_input(date)
      if date.kind_of? Date
        date
      else
        Date.parse(date)
      end
    end

  end
end