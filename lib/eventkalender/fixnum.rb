# TODO: write tests
# This class is used to determine time shifts in parser class
class Fixnum

  SECONDS_IN_DAY     = 24 * 60 * 60
  SECONDS_IN_HOUR    = 60 * 60
  SECONDS_IN_MINUTES = 60

  def days
    self * SECONDS_IN_DAY
  end

  def minutes
    self * SECONDS_IN_MINUTES
  end

  def hours
    self * SECONDS_IN_HOUR
  end

  def ago
    Time.now - self
  end
end