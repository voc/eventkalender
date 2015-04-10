require 'spec_helper'

describe Eventkalender::Scraper do
  before(:each) do
    @scraper = Eventkalender::Scraper.new
  end

  after(:each) do
    @scraper = nil
  end

  describe '#new' do
    # TODO: pending
  end

  describe '.scrape!' do
    it 'should return Nokogiri::XML::Element object' do
      expect(Eventkalender::Scraper.scrape!).to be_instance_of Array
      expect(Eventkalender::Scraper.scrape!.first).to be_instance_of Hash
      expect(Eventkalender::Scraper.scrape!.first[:page]).to be_instance_of Mechanize::Page
    end
  end

  describe '#get_pages' do
    it 'should return array with Mechanize::Page objects' do
      expect(@scraper.get_pages).to be_instance_of Array
      expect(@scraper.get_pages.first).to be_instance_of Hash
      expect(@scraper.get_pages.first[:page]).to be_instance_of Mechanize::Page
    end

    it 'should be possible to change url for this function' do
      stub_request(:get, 'http://c3voc.de/wiki/bla').to_return( body: 'bla' )
      pages = @scraper.get_pages([{ type: :conferences,
                                    url: 'http://c3voc.de/wiki/bla',
                                    xpath: "//*/div[@class='table dataaggregation']/descendant::table[1]" }])

      expect(pages.first[:page].body).to eq 'bla'
    end
  end

  describe '#get_tables' do
    it 'should return an Array with Hashes defined with :table keys as Nokogiri::XML::Element' do
      # TODO: just, wat. (first[:table].first)
      expect(@scraper.get_tables.first[:table].first).to be_instance_of Nokogiri::XML::Element
    end
  end
end
