# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy do
  subject(:strategy) { described_class.new(execution_detector: execution_detector, object_tracker: object_tracker) }

  let(:execution_detector) { instance_double('Crystalball::MapGenerator::ObjectSourcesDetector') }
  let(:object_tracker) { instance_double('Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectTracker') }

  include_examples 'base strategy'

  describe '.build' do
    let(:whitelist) { double }
    let(:root) { double }

    it 'creates a strategy with specified params' do
      fetcher = instance_double('Crystalball::MapGenerator::ObjectSourcesDetector::HierarchyFetcher')
      allow(Crystalball::MapGenerator::ObjectSourcesDetector::HierarchyFetcher).to receive(:new).with(whitelist).and_return(fetcher)

      allow(Crystalball::MapGenerator::ObjectSourcesDetector).to receive(:new).with(root_path: root, hierarchy_fetcher: fetcher).and_return(execution_detector)
      allow(Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectTracker).to receive(:new).with(only_of: whitelist).and_return(object_tracker)

      expect(described_class).to receive(:new).with(execution_detector: execution_detector, object_tracker: object_tracker).once

      described_class.build(only: whitelist, root: root)
    end
  end

  describe '#call' do
    subject { strategy.call(example_group_map, 'example') {} }

    let(:example_group_map) { [] }
    let(:objects) { [] }

    before do
      allow(object_tracker).to receive(:used_classes_during) { objects }.and_yield
      allow(execution_detector).to receive(:detect).with(objects) { [1, 2, 3] }
    end

    it 'yields example_group_map to a block' do
      expect do |b|
        strategy.call(example_group_map, 'example', &b)
      end.to yield_with_args(example_group_map, 'example')
    end

    it 'pushes used files detected by detector to example group map' do
      expect do
        subject
      end.to change { example_group_map }.to [1, 2, 3]
    end
  end
end
