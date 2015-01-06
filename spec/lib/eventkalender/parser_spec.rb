require 'spec_helper'

describe Eventkalender::Parser do

  before(:each) do
    @parser = Eventkalender::Parser.new
    @scraper = Eventkalender::Scraper.new
  end

  after(:each) do
    @parser = nil
  end

  describe '#events' do
    it 'should return an array of events' do
      events = @parser.events

      expect(events.first).to be_instance_of Eventkalender::Conference
      expect(events.last).to be_instance_of Eventkalender::Conference
    end

    it 'should be possible to force scraping' do
      # do not force
      @parser.events
      last_parser_run = @parser.timestamp

      sleep 2

      # force scraping
      @parser.events(force_scraping = true)
      expect(@parser.timestamp.to_s).not_to eq last_parser_run.to_s
    end
  end

  describe '#to_event' do
    it 'should genetrate Eventkalender::Event object' do
      table = @scraper.get_tables
      rows = table.search('./*/tr')

      event = @parser.to_event(rows[2])

      expect(event.name).to            match /Easterhegg 2014/
      expect(event.location).to        match /Stuttgart/
      expect(event.start_date.to_s).to match /2014-04-18/
      expect(event.end_date.to_s).to   match /2014-04-21/
      expect(event.description).to     match /https:\/\/eh14.easterhegg.eu\//
      expect(event.streaming).to       be true
      expect(event.short_name).to      match /easterhegg14/
      expect(event.wiki_path.to_s).to  match /\/wiki\/easterhegg14/
      expect(event.wiki_path).to be_instance_of String
    end
  end

  describe '#to_ical_calendar' do
    it 'should accept a list of events' do
      calendar = @parser.to_ical_calendar

      expect(Icalendar.parse(calendar.to_ical)).to be_instance_of(Array)
    end

    it 'should return valid ical calendar' do
      calendar = @parser.to_ical_calendar

      expect(calendar).to be_instance_of(Icalendar::Calendar)
      expect(Icalendar.parse(calendar.to_ical)).to be_instance_of(Array)
    end
  end

  describe '.date' do
    it 'should return date object' do
      date = Eventkalender::Parser.date('2023-05-23')

      expect(date).to be_instance_of(Date)
    end

    it 'should accept date as a string' do
      date = Eventkalender::Parser.date('2023-05-23')

      expect(date.to_s).to eq '2023-05-23'
    end
  end

  describe '#to_atom' do
    it 'should return valid atom feed' do
      feed = @parser.to_atom

      expect(feed.to_s).to match(/<id>tag:c3voc.de,2014-08-23:6<\/id>/)
    end

    it 'should return atom feed object' do
      feed = @parser.to_atom
      expect(feed).to be_instance_of(RSS::Atom::Feed)
    end
  end

  describe '#to_txt' do
    it 'should return events string' do
      txt = @parser.to_txt

      expect(txt).to be_instance_of(String)
      expect(txt).to match(/FOSSGIS 2014 - Berlin\n19.03.2014 - 21.03.2014\n\n/)
    end
  end

  describe '#to_json' do
    it 'should return events in json' do
      json = @parser.to_json

      expect(json).to be_instance_of(String)
      expect(json).to match(/{\n  \"voc_events\":/)
    end

    it 'should have some statistical data' do
      data = JSON.parse(@parser.to_json)

      expect(data['voc_events_count']['all']).to eq 9
      expect(data['voc_events_count']['with_streaming']).to eq 8
      expect(data['voc_events_count']['without_streaming']).to eq 0
      expect(data['voc_events_count']['undefined_streaming']).to eq 1
    end
  end

  describe '#filter' do
    it 'should filter events' do
      # Overwrite Date.today to have every time same conditions
      Date.stub(:today).and_return(Date.parse('2014-04-15'))

      # case past
      events = @parser.filter( { general: 'past' } )
      expect(events.count).to eq 1
      expect(events.first.name).to match(/FOSSGIS/)

      # case upcoming
      events = @parser.filter( { general: 'upcoming' } )
      expect(events.count).to eq 7

      # case year
      events = @parser.filter( { general: '2014' } )
      expect(events.count).to eq 8

      # case year
      events = @parser.filter( { general:'2013' } )
      expect(events.count).to eq 0

      # default case
      events = @parser.filter( { general: 'random_input' })
      expect(events.count).to eq 8
    end

    it 'should return events array' do
      events = @parser.filter( { general: 'all' } )

      expect(events.last).to be_instance_of(Eventkalender::Conference)
    end

    it 'should accept streaming filter' do
      # Overwrite Date.today to have every time same conditions
      Date.stub(:today).and_return(Date.parse('2014-04-15'))

      # case past, streaming off
      events = @parser.filter( { general: 'past', streaming: 'false' } )
      expect(events.count).to eq 0

      # case past, streaming off
      events = @parser.filter( { general: 'past', streaming: 'true' } )
      expect(events.count).to eq 1
      expect(events.first.name).to match /FOSSGIS/

      # case upcoming, streaming on
      events = @parser.filter( { general: 'upcoming', streaming: 'true' } )
      expect(events.count).to eq 6
      expect(events.last.name).to match /31C3/

      # case upcoming, streaming on, idea event
      events = @parser.filter( { general: 'upcoming', streaming: 'true', idea: 'true' } )
      expect(events.count).to eq 7
      expect(events.last.name).to match /ICMP/
    end
  end

  describe '#filter_streaming' do
    it 'should filter events' do
      # Overwrite Date.today to have every time same conditions
      Date.stub(:today).and_return(Date.parse('2014-04-15'))

      events = @parser.filter_streaming('false')
      expect(events.count).to eq 0

      events = @parser.filter_streaming('true')
      expect(events.count).to eq 8

      events = @parser.filter_streaming('undefined')
      expect(events.count).to eq 1
    end
  end

  describe '#remove_idea_events' do
    it 'should remove events with planing status idea' do
      events = @parser.events
      expect(events.count).to eq 9

      expect(@parser.remove_idea_events(events).count).to eq 8
    end
  end

end
