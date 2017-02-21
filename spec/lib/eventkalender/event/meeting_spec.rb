require 'spec_helper'

describe Eventkalender::Meeting do

  before(:each) do
    @meeting = Eventkalender::Meeting.new(
                    name:           'my todes meeting',
                    type:           'Mumble',
                    location:       'todes location',
                    start_date:     '24.04.1999',
                    end_date:       '24.04.2000',
                    link:           'https://exampele.com',
                    tags:           'a,b,c')
  end

  after(:each) do
    @meeting = nil
  end

  describe '#new' do
    it 'should accept options hash' do
      expect(@meeting.name).to        eq 'my todes meeting'
      expect(@meeting.location).to    eq 'todes location'
      expect(@meeting.start_date).to  eq Date.parse('24.04.1999')
      expect(@meeting.end_date).to    eq Date.parse('24.04.2000')
      expect(@meeting.tags).to        eq ['a', 'b', 'c']
      expect(@meeting.link).to        eq 'https://exampele.com'
    end
  end

end
