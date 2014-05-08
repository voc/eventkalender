# This class overwrites Fixnum in core to adds rails like time handling
# and can be used to determine time shifts.
class Fixnum

  # Define a day in seconds
  SECONDS_IN_DAY     = 24 * 60 * 60
  # Define an hour in seconds
  SECONDS_IN_HOUR    = 60 * 60
  # Define a minute in seconds
  SECONDS_IN_MINUTES = 60

  # Converts given number into days in seconds
  #
  # @example Convert two days into seconds
  #   2.days #=> 172800
  #
  # @return [Fixnum] days in seconds
  def days
    self * SECONDS_IN_DAY
  end

  # Converts given number into minutes in seconds
  #
  # @example Convert two minutes into seconds
  #   2.minutes #=> 120
  #
  # @return [Fixnum] minutes in seconds
  def minutes
    self * SECONDS_IN_MINUTES
  end

  # Converts given number into hours in seconds
  #
  # @example Convert two hours into seconds
  #   2.hours #=> 7200
  #
  # @return [Fixnum] hours in seconds
  def hours
    self * SECONDS_IN_HOUR
  end

  # Rails like helper method to get a timestamp for a given period
  #
  # @example Get date two days ago
  #   2.days.ago #=> 2014-05-06 23:02:46 +0200
  #
  # @return [Time] timestamp in the past for given period
  def ago
    Time.now - self
  end
end