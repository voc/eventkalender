require 'spec_helper'

describe Eventkalender::Parser::Conferences do

  before(:each) do
  end

  after(:each) do
    @parser = nil
  end

  describe '#events' do
    # pending
  end

  describe '#to_txt' do
    it 'should return events string' do
      # pending
    end
  end

  describe '/events.ical?meetings=yes' do
    it 'should generate right ical event format' do
      get '/events.ical?meetings=yes'

      ical_events = last_response.body.split(/BEGIN:VEVENT/).map{ |e| "BEGIN:VEVENT" + e }

      eh_mumble           = ical_events.select{ |e| e =~ /.*eh17-mumble.*/}.first
      maintenance_weekend = ical_events.select{ |e| e =~ /.*maintenance weekend.*/}.first

      # event with start and end time defined
      expect(eh_mumble).to match(/DTSTART:20170330T200000/)
      expect(eh_mumble).to match(/DTEND:20170330T230000/)

      # all day event with more then one day
      # end_date == user_defined_end_date + 1day
      expect(maintenance_weekend).to match(/DTSTART:20161119T000000/)
      expect(maintenance_weekend).to match(/DTEND:20161121T000000/)
    end
  end
end
