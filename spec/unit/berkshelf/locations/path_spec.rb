require 'spec_helper'

module Berkshelf
  describe PathLocation do
    let(:berksfile) { double('berksfile', filepath: __FILE__) }
    let(:constraint) { double('constraint', satisfies?: true) }
    let(:dependency) do
      double('dependency',
        name: 'nginx',
        version_constraint: constraint,
        berksfile: berksfile,
      )
    end
    let(:path) { fixtures_path.join('cookbooks', 'example_cookbook').to_s }
    let(:relative_path) { '../../../fixtures/cookbooks/example_cookbook' }

    subject { described_class.new(dependency, path: path) }

    describe '#download' do
      it 'returns a CachedCookbook' do
        expect(subject.download).to be_a(CachedCookbook)
      end
    end

    describe '#relative_path' do
      it 'returns the path to the Berksfile' do
        expect(subject.relative_path).to eq(relative_path)
      end
    end

    describe '#expanded_path' do
      it 'returns the expanded path, relative to the Berksfile' do
        absolute_path = File.expand_path(relative_path, File.dirname(berksfile.filepath))
        expect(subject.expanded_path).to eq(absolute_path)
      end
    end

    describe '#==' do
      it 'is false when compared with a non-PathLocation' do
        this = PathLocation.new(dependency, path: '.')
        that = 'A string'
        expect(this).to_not eq(that)
      end

      it 'is false when the metadata? is not the same' do
        this = PathLocation.new(dependency, path: '.')
        that = PathLocation.new(dependency, path: '.', metadata: true)
        expect(this).to_not eq(that)
      end

      it 'is false when the expanded paths are different' do
        this = PathLocation.new(dependency, path: '.')
        that = PathLocation.new(dependency, path: '..')
        expect(this).to_not eq(that)
      end

      it 'is true when they are the same' do
        this = PathLocation.new(dependency, path: '.', metadata: true)
        that = PathLocation.new(dependency, path: '.', metadata: true)
        expect(this).to eq(that)
      end
    end

    describe '#to_lock' do
      it 'includes the path relative to the Berksfile' do
        expect(subject.to_lock).to eq <<-EOH.gsub(/^ {10}/, '')
              path: #{relative_path}
        EOH
      end

      it 'includes the metadata attribute' do
        subject.stub(:metadata?).and_return(true)
        expect(subject.to_lock).to eq <<-EOH.gsub(/^ {10}/, '')
              path: #{relative_path}
              metadata: true
        EOH
      end
    end

    describe '#to_s' do
      it 'uses the expanded path' do
        expect(subject.to_s).to eq("source at #{relative_path}")
      end
    end

    describe '#inspect' do
      it 'includes the right information' do
        subject.stub(:metadata?).and_return(true)
        expect(subject.inspect).to eq("#<Berkshelf::PathLocation metadata: true, path: #{relative_path}>")
      end
    end
  end
end
