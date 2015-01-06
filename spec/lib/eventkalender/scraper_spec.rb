require 'spec_helper'

describe Eventkalender::Scraper do
  before(:each) do
    @scraper = Eventkalender::Scraper.new
  end

  after(:each) do
    @scraper = nil
  end

  describe '#new' do
    it 'should set url and xpath class variables' do
      expect(@scraper.url).to match /http/
      expect(@scraper.xpath).to match /div/


      expect(@scraper.page).to be nil
      expect(@scraper.table).to be nil
    end

    it 'should be possible to define url and xpath' do
      scraper = Eventkalender::Scraper.new('http://bla.fasel', "//*/table[@id='flup']")

      expect(scraper.url).to eq 'http://bla.fasel'
      expect(scraper.xpath).to eq "//*/table[@id='flup']"
    end
  end

  describe '.scrape!' do
    it 'should return Nokogiri::XML::Element object' do
      expect(Eventkalender::Scraper.scrape!).to be_instance_of Nokogiri::XML::Element
    end
  end

  describe '#get_page' do
    it 'should return Mechanize::Page object' do
      expect(@scraper.get_page).to be_instance_of Mechanize::Page
    end

    it 'should be possible to change url for this function' do
      stub_request(:get, 'http://c3voc.de/wiki/bla').to_return( body: 'bla' )
      page = @scraper.get_page('http://c3voc.de/wiki/bla')

      expect(page.body).to eq 'bla'
      expect(@scraper.url).to eq 'http://c3voc.de/wiki/events'
    end
  end

  describe '#get_tables' do
    it 'should return Nokogiri::XML::Element object' do
      expect(@scraper.get_tables).to be_instance_of Nokogiri::XML::Element
    end

    it 'should be possible to change xpath pattern for this function' do
      table = @scraper.get_tables('//*[@id="events"]')

      expect(table.text).to eq 'Events'
      expect(@scraper.xpath).to match /div/
    end
  end

  describe '@XPATH' do
    it 'should match right table' do
      table = @scraper.get_tables

      expect(table.search('./tbody/tr').count).to eq 11
      expect(table.search('./tbody/tr[3]/td')[2].text).to eq '2014-04-18'
    end
  end
end
