# frozen_string_literal: true

require 'spec_helper'

describe Eventkalender::Conference do
  before(:each) do
    @event = Eventkalender::Conference.new(name: 'my todes event',
                                           location: 'todes location',
                                           start_date: '24.04.1999',
                                           end_date: '24.04.2000',
                                           description: 'http://example.com',
                                           short_name: 'h5n1',
                                           wiki_path: '/wiki/h5n1',
                                           buildup: '23.04.1999',
                                           teardown: '25.04.2000',
                                           planing_status: '')
  end

  after(:each) do
    @event = nil
  end

  describe '#new' do
    it 'should accept options hash' do
      expect(@event.name).to        eq 'my todes event'
      expect(@event.location).to    eq 'todes location'
      expect(@event.start_date).to  eq Date.parse('24.04.1999')
      expect(@event.end_date).to    eq Date.parse('24.04.2000')
      expect(@event.description).to eq 'http://example.com'
      expect(@event.short_name).to  eq 'h5n1'
      expect(@event.wiki_path).to   eq '/wiki/h5n1'
      expect(@event.buildup).to     eq '23.04.1999'
      expect(@event.teardown).to eq '25.04.2000'
    end
  end

  describe 'getter' do
    it 'should be possible to get name, description, location, start_date and end_date' do
      expect(@event.name).to        eq 'my todes event'
      expect(@event.location).to    eq 'todes location'
      expect(@event.start_date).to  eq Date.parse('24.04.1999')
      expect(@event.end_date).to    eq Date.parse('24.04.2000')
      expect(@event.description).to eq 'http://example.com'
      expect(@event.short_name).to  eq 'h5n1'
      expect(@event.wiki_path).to   eq '/wiki/h5n1'
      expect(@event.buildup).to     eq '23.04.1999'
      expect(@event.teardown).to eq '25.04.2000'
    end
  end

  describe 'setter' do
    it 'should be possible to set event name' do
      @event.name = 'new todes event'
      expect(@event.name).to eq 'new todes event'
    end

    it 'should be possible to set event location' do
      @event.location = 'new todes location'
      expect(@event.location).to eq 'new todes location'
    end

    it 'should be possible to set event description' do
      @event.description = 'new description'
      expect(@event.description).to eq 'new description'
    end

    it 'should be possible to set (voc) event wiki path' do
      @event.wiki_path = '/wiki/url'
      expect(@event.wiki_path.to_s).to eq '/wiki/url'
    end

    it 'should be possible to set event short name' do
      @event.short_name = 'short name'
      expect(@event.short_name).to eq 'short name'
    end
  end

  describe '#check_date_input' do
    it 'should return Date object' do
      # Input String
      date = @event.send(:check_date_input, '2023-05-23')

      expect(date.is_a?(Date)).to be true
      expect(date.to_s).to eq '2023-05-23'

      # Input Date object
      date = @event.send(:check_date_input, Date.parse('24.12.2014'))

      expect(date.is_a?(Date)).to be true
      expect(date.to_s).to eq '2014-12-24'
    end

    it 'should raise invalid date exception for invalid date input' do
      date = @event.send(:check_date_input, '202305')
      date2 = @event.send(:check_date_input, '?')
      expect(date).to be nil
      expect(date2).to be nil
    end

    it 'should return nil if input type is not a String or Date object' do
      date = @event.send(:check_date_input, ['2023-05-23'])
      expect(date).to be nil
    end
  end

  describe '#to_ical' do
    it 'should convert an event to a valid ical event' do
      ical_object = @event.to_ical
      array = ical_object.to_ical.split(/\n/)

      expect(array.first).to match(/BEGIN:VEVENT/)
      expect(array.last).to match(/END:VEVENT/)
      expect(array.include?("DTSTART;VALUE=DATE:19990424\r")).to be true
      expect(array.include?("DTEND;VALUE=DATE:20000425\r")).to be true
      expect(array.include?("SUMMARY:my todes event\r")).to be true
      expect(array.include?("LOCATION:todes location\r")).to be true
    end
  end

  describe '.now?' do
    it 'should return true if an event is now' do
      expect(@event.now?).to be false

      @event.start_date = Date.today
      @event.end_date   = Date.today + 1
      expect(@event.now?).to be true
    end
  end

  describe '.upcoming?' do
    it 'should return true if an event is upcoming' do
      expect(@event.upcoming?).to be false

      @event.start_date = Date.today + 23
      @event.end_date   = Date.today + 42
      expect(@event.upcoming?).to be true
    end
  end

  describe '.past?' do
    it 'should return true when an event lies in the past' do
      expect(@event.past?).to be true

      @event.start_date = Date.today + 23
      @event.end_date   = Date.today + 42
      expect(@event.past?).to be false

      @event.start_date = Date.today
      @event.end_date   = Date.today
      expect(@event.past?).to be false
    end
  end

  describe '.streaming=' do
    it 'should set false, true or nil' do
      # yes, we have streaming on this event
      @event.streaming = 'ja'
      expect(@event.streaming).to be true
      @event.streaming = 'Ja'
      expect(@event.streaming).to be true
      # no streaming
      @event.streaming = 'nein'
      expect(@event.streaming).to be false
      # streaming status is unclear
      @event.streaming = 'vielleicht'
      expect(@event.streaming).to be nil
      @event.streaming = ''
      expect(@event.streaming).to be nil
      @event.streaming = nil
      expect(@event.streaming).to be nil
    end
  end

  describe '.idea?' do
    it 'should return true when supporting the event is only an idea' do
      expect(@event.idea?).to be false

      @event.planing_status = 'idea'
      expect(@event.idea?).to be true
    end
  end
end
