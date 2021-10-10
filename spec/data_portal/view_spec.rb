require 'spec_helper'

class MyView
  include DataPortal::View

  attribute :id
end

RSpec.describe DataPortal::View do
  context 'class methods' do
    describe '.attribute' do
      it 'creates a standard attribute' do
        v = MyView.new ids: [123]
        expect(v.attributes.size).to eq 1
        expect(v.attributes[:id]).to_not be nil
        expect(v.attributes[:id]).to be_a DataPortal::Attributes::Standard
      end
    end
  end
end
