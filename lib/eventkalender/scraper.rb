require 'mechanize'

class Eventkalender
  # Web crawler that can be found event table.
  #
  # @example Get event page.
  #   scraper = Eventkalender::Scraper.new
  #   scraper.get_page #=>  #<Eventkalender::Scraper:0x0000000148c3c0 @url="http://c3voc.de/wiki/events", @xpath=" … ">
  #
  # @example Get event table without initialising a scraper object.
  #   Eventkalender::Scraper.scrape! #=> #<Nokogiri::XML::Element:0xbd5740 name="table" … >
  #
  # @!attribute [rw] url
  #   @return [String] URL for webpage that holds events.
  # @!attribute [rw] xpath
  #   @return [String] XPATH to find event table.
  # @!attribute [r] page
  #   @return [Mechanize::Page] That holds events.
  # @attribute [r] table
  #   @return [Nokogiri::XML::Element] That holds events.
  class Scraper

    # web page to scrape
    PAGES_TO_SCRAPE = [
      { type: :conferences,
        url: 'http://c3voc.de/wiki/eventz',
        xpath: "//*/descendant::table[1]" },
      { type: :meetings,
        url: 'http://c3voc.de/wiki/meetingz',
        xpath: "//*/descendant::table[1]" }
    ]

    attr_reader :pages, :tables

    # Class initializer for scraper class.
    #
    # @example Create new scraper
    #   Eventkalender::Scraper.new #=> #<Eventkalender::Scraper:0x00000003eeb7d8 @url="…", @xpath="…">
    #
    # @param url [String, URL] to parse
    # @param xpath [String, XPATH] to find event table
    def initialize
      @pages # TODO: should be removed?
    end

    # Instance method to run scraper.
    #
    # @example Start web page scraping with initialized scraper
    #   scraper.scrape #=> #<Nokogiri::XML::Element:0x1290224 name="table" … >
    #
    # @return [Nokogiri::XML::Element] scrapped event table
    def scrape
      get_tables
    end

    # Class method to scrape events page without initialize own scraper instance.
    #
    # @example Start scraper
    #   Eventkalender::Scraper.scrape! #=> #<Nokogiri::XML::Element:0x1290224 name="table" … >
    #
    # @return [Nokogiri::XML::Element] scrapped event table
    def self.scrape!
      scraper = self.new
      scraper.scrape
    end

    # Initialize mechanize object to get events page.
    #
    # @param page [String] URL to scrape
    # @return [Mechanize::Page] events page
    def get_pages(urls = PAGES_TO_SCRAPE)
      # Create agent
      agent = Mechanize.new
      agent.user_agent = "eventkalender/#{Eventkalender::VERSION} "\
                         "(https://github.com/voc/eventkalender)"
      # create copy of PAGES_TO_SCRAPE
      @pages = urls.clone
      # Get web page
      urls.each do |page|
        page[:page] = agent.get(page[:url])
      end

      @pages
    end

    # Search xpath expression in events page and returned xml events table.
    #
    # @param xpath [Array] xpath pattern
    # @return [Nokogiri::XML::Element] Events table
    def get_tables(pages = get_pages)
      pages.each do |page|
        page[:table]     = page[:page].search(page[:xpath])
        page[:timestamp] = Time.now
      end

      pages
    end
  end
end
