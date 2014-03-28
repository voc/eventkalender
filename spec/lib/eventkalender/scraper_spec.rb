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
      @scraper.url.should =~ /http/
      @scraper.xpath.should =~ /div/


      @scraper.page.should be_nil
      @scraper.table.should be_nil
    end

    it 'should be possible to define url and xpath' do
      scraper = Eventkalender::Scraper.new('http://bla.fasel', "//*/table[@id='flup']")

      scraper.url.should == 'http://bla.fasel'
      scraper.xpath.should == "//*/table[@id='flup']"
    end
  end

  describe '.scrape!' do
    it 'should return Nokogiri::XML::Element object' do
      Eventkalender::Scraper.scrape!.class.should == Nokogiri::XML::Element
    end
  end

  describe '#get_page' do
    it 'should return Mechanize::Page object' do
      @scraper.get_page.class.should == Mechanize::Page
    end

    it 'should be possible to change url for this function' do
      stub_request(:get, "http://c3voc.de/wiki/bla").to_return( body: 'bla' )
      page = @scraper.get_page('http://c3voc.de/wiki/bla')

      page.body.should == 'bla'
      @scraper.url.should == 'http://c3voc.de/wiki/events'
    end
  end

  describe '#get_table' do
    it 'should return Nokogiri::XML::Element object' do
      @scraper.get_table.class.should == Nokogiri::XML::Element
    end

    it 'should be possible to change xpath pattern for this function' do
      table = @scraper.get_table('//*[@id="events"]')

      table.text.should == 'Events'
      @scraper.xpath.should =~ /div/
    end
  end

  describe '@XPATH' do
    it 'should match right table' do
      table = @scraper.get_table

      table.search('./tbody/tr').count.should == 10
      table.search('./tbody/tr[3]/td')[2].text.should == '2014-04-18'
    end
  end
end