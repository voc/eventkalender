require 'spec_helper'

describe Eventkalender::Event do

  before(:each) do
    @event = Eventkalender::Event.new( name: 'my todes event',
                                       location: 'todes location',
                                       start_date: '24.04.1999',
                                       end_date: '24.04.2000',
                                       describtion: 'http://example.com'
    )
  end

  after(:each) do
    @event = nil
  end

  describe '#new' do
    it 'should accept options hash' do
      event = @event

      event.name.should == 'my todes event'
      event.location.should == 'todes location'
      event.start_date.should == Date.parse('24.04.1999')
    end
  end

  describe 'getter' do
    it 'should be possible to get name' do
      @event.location.should == 'todes location'
    end

  end

  describe 'setter' do
    it 'should be possible to set event name' do
      @event.name = 'new todes event'
      @event.name.should == 'new todes event'
    end

    it 'should be possible to set event location' do
      @event.location = 'new todes location'
      @event.location.should == 'new todes location'
    end
  end

  describe '#check_date_input' do
    it 'should return Date object' do
      date = @event.send(:check_date_input, '2023-05-23')

      date.kind_of?(Date).should be_true
      date.to_s.should == '2023-05-23'

      date = @event.send(:check_date_input, Date.parse('24.12.2014'))

      date.kind_of?(Date).should be_true
      date.to_s.should == '2014-12-24'
    end
  end

  describe '#to_ical' do
    it 'should convert an event to a valid ical event' do
      ical = Icalendar::Event.new
      ical.summary     = 'my todes event'
      ical.location    = 'todes location'
      ical.start       = Date.parse('24.04.1999')
      ical.end         = Date.parse('24.04.2000')

      ical_object = @event.to_ical
      array = ical_object.to_ical.split(/\n/)

      array.first.should =~ /BEGIN:VEVENT/
      array.last.should =~ /END:VEVENT/
      array.include?("DTSTART:19990424\r").should be_true
      array.include?("DTEND:20000425\r").should be_true
      array.include?("SUMMARY:my todes event\r").should be_true
      array.include?("LOCATION:todes location\r").should be_true

      example_ical = <<EOS
BEGIN:VEVENT
DTEND:20000425
DTSTAMP:20140327T191030Z
DTSTART:19990424
LOCATION:todes location
SEQUENCE:0
SUMMARY:my todes event
UID:2014-03-27T20:10:30+01:00_669871828@jihahihihi
END:VEVENT
EOS
    end
  end
end