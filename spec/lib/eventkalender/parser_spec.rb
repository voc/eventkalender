require 'spec_helper'

describe Eventkalender::Parser do

  before(:each) do
    @parser = Eventkalender::Parser.new
  end

  after(:each) do
    @parser = nil
  end

  describe '#events' do
    it 'should return an array of events' do
      events = @parser.events

      events.first.class.should be Eventkalender::Event
      events.last.class.should be Eventkalender::Event
    end

    it 'should be possible to force scraping' do
      # force scraping
      @parser.events(force_scraping = true)
      current_time = Time.now

      @parser.timestamp.to_s.should == current_time.to_s

      sleep 1

      # do not force
      @parser.events
      @parser.timestamp.to_s.should_not == Time.now.to_s
    end
  end

  describe '#to_ical_calendar' do
    it 'should accept a list of events' do
      calendar = @parser.to_ical_calendar

      Icalendar.parse(calendar.to_ical).should be_true
    end

    it 'should return valid ical calendar' do
      calendar = @parser.to_ical_calendar

      calendar.class.should be Icalendar::Calendar
      Icalendar.parse(calendar.to_ical).should be_true
    end
  end

  describe '.date' do
    it 'should return date object' do
      date = Eventkalender::Parser.date('2023-05-23')

      date.class.should == Date
    end

    it 'should accept date as a string' do
      date = Eventkalender::Parser.date('2023-05-23')

      date.to_s.should == '2023-05-23'
    end
  end

  describe '#to_atom' do
    it 'should return valid atom feed' do
      feed = @parser.to_atom

      feed.to_s.should =~ /FrOSCon82014-08-232014-08-24/
    end

    it 'should return atom feed object' do
      feed = @parser.to_atom
      feed.class.should == RSS::Atom::Feed
    end
  end

  describe '#to_txt' do
    it 'should return events string' do
      txt = @parser.to_txt

      txt.class.should == String
      txt.should =~ /FrOSCon 8/
    end
  end

  describe '#to_json' do
    it 'should return events in json' do
      json = @parser.to_json

      json.class.should == String
      json.should =~ /{"voc_events"/
    end
  end

  describe '#filter' do
    it 'should filter events' do
      events = @parser.filter('past')
      events.count.should be 1

      events = @parser.filter('upcoming')
      events.count.should be 7

      events = @parser.filter('2014')
      events.count.should be 8

      events = @parser.filter('2013')
      events.count.should be 0

      events = @parser.filter('random_input')
      events.count.should be 8
    end

    it 'should return events array' do
      events = @parser.filter('all')

      events.last.class.should == Eventkalender::Event
    end
  end
end