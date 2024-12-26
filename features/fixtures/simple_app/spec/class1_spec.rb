# frozen_string_literal: true

require 'spec_helper'

describe Class1 do
  let(:name) { 'John Doe' }

  include_examples 'module1'

  describe '#bar' do
    subject { super().bar }

    it { is_expected.to eq 'bar of Class1' }
  end
end
