require 'spec_helper'

describe Eventkalender::Meeting do

  before(:each) do
    @meeting = Eventkalender::Meeting.new(
                    name:           'my todes event',
                    type:           'Mumble',
                    location:       'todes location',
                    start_date:     '24.04.1999',
                    end_date:       '24.04.2000')
  end

  after(:each) do
    @meeting = nil
  end

end
