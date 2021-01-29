describe RailsCloudTasks do
  describe '#queue_adapter' do
    subject(:queue_adapter) { described_class.queue_adapter }

    before do
      described_class.instance_variable_set('@queue_adapter', nil)
    end

    context 'when the adapter is loaded successfuly' do
      let(:adapter) { instance_spy(described_class::Adapter) }

      before do
        allow(described_class::Adapter).to receive(:new).and_return(adapter)
      end

      it { is_expected.to be_instance_of(adapter.class) }
    end

    context 'when the adpter could not be loaded' do
      let(:error) { StandardError.new }

      before do
        allow(Rails).to receive(:env).and_return(environment.inquiry)
        allow(described_class::Adapter).to receive(:new).and_raise(error)
      end

      context 'when the environment is not development' do
        let(:environment) { 'production' }

        it do
          expect { queue_adapter }.to raise_error(error)
        end
      end

      context 'when the environment is development' do
        let(:logger) { instance_spy(Logger) }
        let(:environment) { 'development' }

        before { allow(described_class).to receive(:logger).and_return(logger) }

        it { is_expected.to eq(:inline) }

        it do
          queue_adapter
          expect(logger).to have_received(:warn)
            .with('unable to setup adapter, falling back to :inline')
        end

        it do
          queue_adapter
          expect(logger).to have_received(:warn).with(error)
        end
      end
    end
  end
end
