require_relative 'eventkalender/event/event'
require_relative 'eventkalender/event/meeting'
require_relative 'eventkalender/event/conference'

require_relative 'eventkalender/parser/parser'
require_relative 'eventkalender/parser/conferences'
require_relative 'eventkalender/parser/meetings'

require_relative 'eventkalender/scraper'
require_relative 'eventkalender/fixnum'

# Main class witch holds version number and application name.
# The real magic is done by all in sub classes.
class Eventkalender

  # eventkalender version number
  VERSION = '1.1.0'
  # application name
  NAME    = 'eventkalender'

end
