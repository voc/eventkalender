require 'spec_helper'

describe 'Webpage eventkalender' do
  describe '/events.ical' do
    it 'should return valid response on GET' do
      get '/events.ical'

      last_response.should be_ok
    end

    it 'should return valid ical feed' do
      get '/events.ical'

      last_response.body.should =~ /END:VCALENDAR/
      last_response.body.should =~ /SUMMARY:FrOSCon/
    end
  end

  describe '/events.atom' do
    it 'should return valid response on GET' do
      get '/events.atom'

      last_response.should be_ok
    end

    it 'should return valid atom feed' do
      get '/events.atom'

      RSS::Parser.parse(last_response.body).should be_true
    end
  end

  describe '/events.txt'  do
    it 'should return valid response on GET' do
      get '/events.txt'

      last_response.should be_ok
    end

    it 'should return text data' do
      get '/events.txt'

      last_response.body.should =~ /31C3 - Hamburg/
      last_response.status.should be 200
    end
  end

  describe '/events.json' do
    it 'should return valid response on GET' do
      get '/events.json'

      last_response.should be_ok
    end

    it 'should return valid json on GET' do
      get '/events.json'

      JSON.parse(last_response.body).should be_true
    end
  end

  describe '/events.html' do
    it 'should return valid response on GET' do
      get '/events.html'

      last_response.should be_ok
    end

    it 'should render events html page on GET' do
      get '/events.html'

      last_response.body.should =~ /past and upcoming/
    end

    it 'should render events html page with defined filter on GET' do
      get '/events.html?filter=past'

      last_response.body.should =~ /Berlin/
      last_response.body.should_not =~ /Augustin/
    end

    it 'should render event description as html link' do
      get '/events.html'

      last_response.body.should =~ /keine webseite/
      last_response.body.should_not =~ />keine webseite<\/a>/
    end
  end

  describe '/' do
    it 'should return valid response on GET' do
      get '/'

      last_response.should be_ok
    end

    it 'should render index template on GET' do
      get '/'

      last_response.body.should =~ /c3voc events/
    end
  end
end