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
    URL   = 'http://c3voc.de/wiki/events'
    # xpath to find events table
    XPATH = "//*/div[@class='level2']/descendant::table[1]"

    attr_accessor :url, :xpath
    attr_reader   :page, :table

    # Class initializer for scraper class.
    #
    # @example Create new scraper
    #   Eventkalender::Scraper.new #=> #<Eventkalender::Scraper:0x00000003eeb7d8 @url="…", @xpath="…">
    #
    # @param url [String, URL] to parse
    # @param xpath [String, XPATH] to find event table
    def initialize(url = URL, xpath = XPATH)
      @url   = url
      @xpath = xpath
    end

    # Instance method to run scraper.
    #
    # @example Start web page scraping with initialized scraper
    #   scraper.scrape #=> #<Nokogiri::XML::Element:0x1290224 name="table" … >
    #
    # @return [Nokogiri::XML::Element] scrapped event table
    def scrape
      get_table
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
    def get_page(page = @url)
      # Create agent
      agent = Mechanize.new
      agent.user_agent = "eventkalender/#{Eventkalender::VERSION} "\
                         "(https://github.com/voc/eventkalender)"

      # Get web page
      @page = agent.get(page)
    end

    # Search xpath expression in events page and returned xml events table.
    #
    # @param xpath [String] xpath pattern
    # @return [Nokogiri::XML::Element] Events table
    def get_table(xpath = @xpath)
      @table = get_page.search(xpath).first
    end

  end
end
