require 'spec_helper'

describe Eventkalender::Event do

  before(:each) do
    @event = Eventkalender::Event.new(name:        'my todes event',
                                      location:    'todes location',
                                      start_date:  '24.04.1999',
                                      end_date:    '24.04.2000',
                                      description: 'http://example.com',
                                      short_name:  'h5n1',
                                      wiki_path:    '/wiki/h5n1',
                                      planing_status: '')
  end

  after(:each) do
    @event = nil
  end

  describe '#new' do
    it 'should accept options hash' do
      @event.name.should        == 'my todes event'
      @event.location.should    == 'todes location'
      @event.start_date.should  == Date.parse('24.04.1999')
      @event.end_date.should    == Date.parse('24.04.2000')
      @event.description.should == 'http://example.com'
      @event.short_name.should  == 'h5n1'
      @event.wiki_path.should   == '/wiki/h5n1'
    end
  end

  describe 'getter' do
    it 'should be possible to get name, description, location, start_date and end_date' do
      @event.name.should        == 'my todes event'
      @event.location.should    == 'todes location'
      @event.start_date.should  == Date.parse('24.04.1999')
      @event.end_date.should    == Date.parse('24.04.2000')
      @event.description.should == 'http://example.com'
      @event.short_name.should  == 'h5n1'
      @event.wiki_path.should   == '/wiki/h5n1'
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

    it 'should be possible to set event description' do
      @event.description = 'new description'
      @event.description.should == 'new description'
    end

    it 'should be possible to set (voc) event wiki path' do
      @event.wiki_path = '/wiki/url'
      @event.wiki_path.to_s.should == '/wiki/url'
    end

    it 'should be possible to set event short name' do
      @event.short_name = 'short name'
      @event.short_name.should == 'short name'
    end
  end

  describe '#check_date_input' do
    it 'should return Date object' do
      # Input String
      date = @event.send(:check_date_input, '2023-05-23')

      date.kind_of?(Date).should be_true
      date.to_s.should == '2023-05-23'

      # Input Date object
      date = @event.send(:check_date_input, Date.parse('24.12.2014'))

      date.kind_of?(Date).should be_true
      date.to_s.should == '2014-12-24'
    end

    it 'should raise invalid date exception for invalid date input' do
      expect {
        @event.send(:check_date_input, '202305')
      }.to raise_error(ArgumentError)
    end

    it 'should return nil if input type is not a String or Date object' do
      date = @event.send(:check_date_input, ['2023-05-23'])
      date.should be_nil
    end
  end

  describe '#to_ical' do
    it 'should convert an event to a valid ical event' do
      ical_object = @event.to_ical
      array = ical_object.to_ical.split(/\n/)

      array.first.should =~ /BEGIN:VEVENT/
      array.last.should =~ /END:VEVENT/
      array.include?("DTSTART;VALUE=DATE:19990424\r").should be_true
      array.include?("DTEND;VALUE=DATE:20000425\r").should be_true
      array.include?("SUMMARY:my todes event\r").should be_true
      array.include?("LOCATION:todes location\r").should be_true
    end
  end

  describe '.now?' do
    it 'should return true if an event is now' do
      @event.now?.should be_false

      @event.start_date = Date.today
      @event.end_date = Date.today + 1
      @event.now?.should be_true
    end
  end

  describe '.upcoming?' do
    it 'should return true if an event is upcoming' do
      @event.upcoming?.should be_false

      @event.start_date = Date.today + 23
      @event.end_date = Date.today + 42
      @event.upcoming?.should be_true
    end
  end

  describe '.past?' do
    it 'should return true when an event lies in the past' do
      @event.past?.should be_true

      @event.start_date = Date.today + 23
      @event.end_date = Date.today + 42
      @event.past?.should be_false

      @event.start_date = Date.today
      @event.end_date = Date.today
      @event.past?.should be_false
    end
  end

  describe '.streaming=' do
    it 'should set false, true or nil' do
      # yes, we have streaming on this event
      @event.streaming= 'ja'
      @event.streaming.should be_true
      @event.streaming= 'Ja'
      @event.streaming.should be_true
      # no streaming
      @event.streaming= 'nein'
      @event.streaming.should be_false
      # streaming status is unclear
      @event.streaming= 'vielleicht'
      @event.streaming.should be_nil
      @event.streaming= ''
      @event.streaming.should be_nil
      @event.streaming= nil
      @event.streaming.should be_nil
    end
  end

  describe '.idea?' do
    it 'should return true when supporting the event is only an idea' do
      @event.idea?.should be_false

      @event.planing_status = 'idea'
      @event.idea?.should be_true
    end
  end
end
