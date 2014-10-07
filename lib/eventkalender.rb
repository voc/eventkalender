require_relative 'eventkalender/event/event'
require_relative 'eventkalender/event/mumble'
require_relative 'eventkalender/event/conference'

require_relative 'eventkalender/parser'
require_relative 'eventkalender/scraper'
require_relative 'eventkalender/fixnum'

# Main class witch holds version number and application name.
# The real magic is done by all in sub classes.
class Eventkalender

  # eventkalender version number
  VERSION = '0.0.10'
  # application name
  NAME    = 'eventkalender'

end
