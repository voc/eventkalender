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
    PAGES_TO_SCRAPE = {
      events: {
        url: 'http://c3voc.de/wiki/events',
        xpath: "//*/div[@class='level2']/div[@class='table dataaggregation']/descendant::table[1]"
      },
      meetings: {
        url: 'http://c3voc.de/wiki/meetings',
        xpath: "//*/div[@class='level1']/descendant::table[1]"
      }
    }

    attr_accessor :url, :xpath
    attr_reader   :pages, :tables

    # Class initializer for scraper class.
    #
    # @example Create new scraper
    #   Eventkalender::Scraper.new #=> #<Eventkalender::Scraper:0x00000003eeb7d8 @url="…", @xpath="…">
    #
    # @param url [String, URL] to parse
    # @param xpath [String, XPATH] to find event table
    def initialize
      @pages  = []
      @tables = []
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
    def get_pages(urls = pages_to_scrape_urls)
      # Create agent
      agent = Mechanize.new
      agent.user_agent = "eventkalender/#{Eventkalender::VERSION} "\
                         "(https://github.com/voc/eventkalender)"

      # Get web page
      urls.each do |url|
        @pages << agent.get(url)
      end

      @pages
    end

    # Search xpath expression in events page and returned xml events table.
    #
    # @param xpath [Array] xpath pattern
    # @return [Nokogiri::XML::Element] Events table
    def get_tables(pages = get_pages, pages_to_scrape = PAGES_TO_SCRAPE)
      pages.each do |page|
        xpath = select_xpath(page.uri.to_s)
        @tables << page.search(xpath)
      end

      @tables
    end

    protected

    # TODO: write tests and docu
    def pages_to_scrape_urls(pages_hash = PAGES_TO_SCRAPE)
      pages_hash.keys.map{|key| pages_hash[key][:url]}
    end

    # TODO: write tests and docu
    def select_xpath(url, data = PAGES_TO_SCRAPE)
      hash = data.select{|k,h| h[:url] == url}
      hash.flatten.last[:xpath]
    end
  end
end
