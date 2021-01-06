describe RailsCloudTasks::JobsController, type: :controller do
  routes { RailsCloudTasks::Engine.routes }

  describe 'POST perform' do
    context 'when the job exists' do
      it 'executes the job' do
        post :perform, { params: { job_name: 'RailsCloudTasks::Job' } }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the job does not exist' do
      it 'renders not found' do
        post :perform, { params: { job_name: 'Foo' } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
