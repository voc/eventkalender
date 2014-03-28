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

  describe 'GET /events.txt'  do
    it 'should return valid response on GET' do
      get '/events.txt'

      last_response.should be_ok
    end

    it 'should return text data' do
      get '/events.txt'

      last_response.body.should =~ /31C3 - Hamburg/
    end
  end

  describe '/events.json' do
    it 'should return valid json on GET' do
      get '/events.json'

      JSON.parse(last_response.body).should be_true
    end
  end
end