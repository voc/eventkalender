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
  end

  describe '.to_ical_calendar' do
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
end