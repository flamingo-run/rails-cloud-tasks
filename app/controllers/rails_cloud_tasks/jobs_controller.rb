module RailsCloudTasks
  class JobsController < ::ActionController::Base
    def perform
      job_name = params.delete(:job_name)

      return render_not_found(job_name) unless RailsCloudTasks.config.jobs.include?(job_name)

      job_name.constantize.perform_now(params)

      render json: {}, status: :ok
    end

    private

    def render_not_found(job_name)
      render json: { error: "Job '#{job_name}' not found" }, status: :not_found
    end
  end
end
