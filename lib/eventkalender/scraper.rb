# gem
require 'mechanize'

class Eventkalender
  class Scraper

    URL   = 'http://c3voc.de/wiki/events'
    XPATH = "//*/div[@class='level2']/descendant::table[1]"

    attr_accessor :url, :xpath  # getter and setter
    attr_reader   :page, :table # getter only

    # Class initializer for scraper class
    #
    # @param [String,String] url, xpath
    def initialize(url = URL, xpath = XPATH)
      @url   = url
      @xpath = xpath
    end

    # Class method to run scraper
    #
    # @return [Nokogiri::XML::Element] Table] table
    def scrape
      get_table
    end

    # Scrape events page to get events table
    #
    # @return [Nokogiri::XML::Element] Table
    def self.scrape!
      scraper = self.new
      scraper.scrape
    end

    # Initialize mechanize object to get events page
    #
    # @param [String] page URL to scrape
    # @return [Mechanize::Page] events page
    def get_page(page = @url)
      # Create agent
      agent = Mechanize.new
      agent.user_agent = 'eventkalender (https://github.com/voc/eventkalender)'

      # Get web page
      @page = agent.get(page)
    end

    # Search xpath expression in events page and returned xml events table
    #
    # @param [String] xpath pattern
    # @return [Nokogiri::XML::Element] Events table
    def get_table(xpath = @xpath)
      @table = get_page.search(xpath).first
    end

  end
end