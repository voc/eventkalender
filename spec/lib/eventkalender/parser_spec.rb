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

      events.first.class.should be Eventkalender::Event
      events.last.class.should be Eventkalender::Event
    end

    it 'should be possible to force scraping' do
      # do not force
      @parser.events
      last_parser_run = @parser.timestamp

      sleep 2

      # force scraping
      @parser.events(force_scraping = true)
      @parser.timestamp.to_s.should_not == last_parser_run.to_s
    end
  end

  describe '#to_event' do
    it 'should genetrate Eventkalender::Event object' do
      table = @scraper.get_table
      rows = table.search('./*/tr')

      event = @parser.to_event(rows[2])
      event.name.should            =~ /Easterhegg 2014/
      event.location.should        =~ /Stuttgart/
      event.start_date.to_s.should =~ /2014-04-18/
      event.end_date.to_s.should   =~ /2014-04-21/
      event.description.should     =~ /https:\/\/eh14.easterhegg.eu\//
      event.streaming.should       == true
      event.short_name.should      =~ /easterhegg14/
      event.wiki_path.to_s.should  =~ /\/wiki\/easterhegg14/
      event.wiki_path.class.should be String
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

      feed.to_s.should =~ /<id>tag:c3voc.de,2014-08-23:6<\/id>/
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
      txt.should =~ /FOSSGIS 2014 - Berlin\n19.03.2014 - 21.03.2014\n\n/
    end
  end

  describe '#to_json' do
    it 'should return events in json' do
      json = @parser.to_json

      json.class.should == String
      json.should =~ /{\n  \"voc_events\":/
    end

    it 'should have some statistical data' do
      data = JSON.parse(@parser.to_json)

      data['voc_events_count']['all'].should be 9
      data['voc_events_count']['with_streaming'].should be 8
      data['voc_events_count']['without_streaming'].should be 0
      data['voc_events_count']['undefined_streaming'].should be 1
    end
  end

  describe '#filter' do
    it 'should filter events' do
      # Overwrite Date.today to have every time same conditions
      Date.stub(:today).and_return(Date.parse('2014-04-15'))

      # case past
      events = @parser.filter( { general: 'past' } )
      events.count.should be 1
      events.first.name.should =~ /FOSSGIS/

      # case upcoming
      events = @parser.filter( { general: 'upcoming' } )
      events.count.should be 8

      # case year
      events = @parser.filter( { general: '2014' } )
      events.count.should be 9

      # case year
      events = @parser.filter( { general:'2013' } )
      events.count.should be 0

      # default case
      events = @parser.filter( { general: 'random_input' })
      events.count.should be 9

      # case today
      date_today = Date.parse('Mai 23 1942')
      # overwrite Date.today
      Date.stub(:today).and_return(date_today)

      events = @parser.events
      events.last.start_date, events.first.start_date = date_today, date_today
      events.last.end_date, events.first.end_date     = date_today, date_today + 1

      @parser.filter( { general: 'today' }, events).count.should be 2
    end

    it 'should return events array' do
      events = @parser.filter( { general: 'all' } )

      events.last.class.should == Eventkalender::Event
    end

    it 'should accept streaming filter' do
      # Overwrite Date.today to have every time same conditions
      Date.stub(:today).and_return(Date.parse('2014-04-15'))

      # case past, streaming off
      events = @parser.filter( { general: 'past', streaming: 'false' } )
      events.count.should be 0

      # case past, streaming off
      events = @parser.filter( { general: 'past', streaming: 'true' } )
      events.count.should be 1
      events.first.name.should =~ /FOSSGIS/

      # case upcoming, streaming on
      events = @parser.filter( { general: 'upcoming', streaming: 'true' } )
      events.count.should be 7
      events.last.name.should =~ /ICMP/
    end
  end

  describe '#filter_streaming' do
    it 'should filter events' do
      # Overwrite Date.today to have every time same conditions
      Date.stub(:today).and_return(Date.parse('2014-04-15'))

      events = @parser.filter_streaming('false')
      events.count.should be 0

      events = @parser.filter_streaming('true')
      events.count.should be 8

      events = @parser.filter_streaming('undefined')
      events.count.should be 1
    end
  end

  describe '#remove_idea_events' do
    it 'should remove events with planing status idea' do
      events = @parser.events
      events.count.should be 9

      @parser.remove_idea_events(events).count.should be 8
    end
  end

end
