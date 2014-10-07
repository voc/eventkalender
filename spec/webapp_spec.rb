require 'spec_helper'

describe 'Webpage eventkalender' do
  describe '/events.ical' do
    it 'should return valid response on GET' do
      get '/events.ical'

      expect(last_response).to be_ok
    end

    it 'should return valid ical feed' do
      get '/events.ical'

      expect(last_response.body).to match /END:VCALENDAR/
      expect(last_response.body).to match /SUMMARY:FrOSCon/
    end
  end

  describe '/events.atom' do
    it 'should return valid response on GET' do
      get '/events.atom'

      expect(last_response).to be_ok
    end

    it 'should return valid atom feed' do
      get '/events.atom'

      expect(RSS::Parser.parse(last_response.body)).to be_instance_of(RSS::Atom::Feed)
    end
  end

  describe '/events.txt'  do
    it 'should return valid response on GET' do
      get '/events.txt'

      expect(last_response).to be_ok
    end

    it 'should return text data' do
      get '/events.txt'

      expect(last_response.body).to match /31C3 - Hamburg/
      expect(last_response.status).to eq 200
    end
  end

  describe '/events.json' do
    it 'should return valid response on GET' do
      get '/events.json'

      expect(last_response).to be_ok
    end

    it 'should return valid json on GET' do
      get '/events.json'

      expect(JSON.parse(last_response.body)).to be_instance_of(Hash)
    end
  end

  describe '/events.html' do
    it 'should return valid response on GET' do
      get '/events.html'

      expect(last_response).to be_ok
    end

    it 'should render events html page on GET' do
      get '/events.html'

      expect(last_response.body).to match(/past and upcoming/)
    end

    it 'should render events html page with defined filter on GET' do
      get '/events.html?filter=past'

      expect(last_response.body).to match(/Berlin/)
      expect(last_response.body).not_to match(/Hamburg/)
    end

    it 'should render event description as html link' do
      get '/events.html'

      expect(last_response.body).to match(/keine webseite/)
      expect(last_response.body).not_to match(/>keine webseite<\/a>/)
    end
  end

  describe '/' do
    it 'should return valid response on GET' do
      get '/'

      expect(last_response).to be_ok
    end

    it 'should render index template on GET' do
      get '/'

      expect(last_response.body).to match(/c3voc events/)
    end
  end
end
