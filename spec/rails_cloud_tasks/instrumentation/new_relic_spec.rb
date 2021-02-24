describe RailsCloudTasks::Instrumentation::NewRelic do
  subject(:intrumentation_new_relic) { described_class.new }

  let(:agent_client) do
    Class.new { def self.set_transaction_name(opts); end } # rubocop:disable Naming/AccessorMethodName
  end

  let(:agent) { class_spy(agent_client) }

  describe '#transaction_name!' do
    subject(:transaction_name!) { intrumentation_new_relic.transaction_name!(params) }

    let(:params) { 'ABC/123' }

    before do
      allow(intrumentation_new_relic).to receive(:agent).and_return(agent)
    end

    it do
      transaction_name!
      expect(agent).to have_received(:set_transaction_name).with(params)
    end
  end
end
