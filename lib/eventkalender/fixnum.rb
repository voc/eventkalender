# frozen_string_literal: true

# This class overwrites Integer in core to adds rails like time handling
# and can be used to determine time shifts.
#
# @example
#   1.day.ago #=> 2014-05-08 23:02:46 +0200
# @example
#   23.hours.ago #=> 2014-05-08 12:12:49 +0200
class Integer
  # a day in seconds
  SECONDS_IN_DAY     = 24 * 60 * 60
  # an hour in seconds
  SECONDS_IN_HOUR    = 60 * 60
  # a minute in seconds
  SECONDS_IN_MINUTES = 60

  # Converts given number into days in seconds.
  #
  # @example Convert two days into seconds
  #   2.days #=> 172800
  #
  # @return [Integer] days in seconds
  def days
    self * SECONDS_IN_DAY
  end

  # Converts given number into minutes in seconds.
  #
  # @example Convert two minutes into seconds
  #   2.minutes #=> 120
  #
  # @return [Integer] minutes in seconds
  def minutes
    self * SECONDS_IN_MINUTES
  end

  # Converts given number into hours in seconds.
  #
  # @example Convert two hours into seconds
  #   2.hours #=> 7200
  #
  # @return [Integer] hours in seconds
  def hours
    self * SECONDS_IN_HOUR
  end

  # Rails like helper method to get a timestamp for a given period.
  #
  # @example Get date two days ago
  #   2.days.ago #=> 2014-05-06 23:02:46 +0200
  #
  # @return [Time] timestamp in the past for given period
  def ago
    Time.now - self
  end
end
