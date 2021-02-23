describe RailsCloudTasks::Instrumentation::Factory do
  subject(:factory) { described_class }

  describe '#agent_class' do
    subject(:agent_class) { factory.agent_class }

    context 'when NewRelic constant is not defined' do
      it { is_expected.to eq(RailsCloudTasks::Instrumentation::Default) }
    end

    context 'when NewRelic constant is defined' do
      before do
        stub_const('NewRelic', Class.new)
      end

      it { is_expected.to eq(RailsCloudTasks::Instrumentation::NewRelic) }
    end
  end
end
