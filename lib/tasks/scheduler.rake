namespace :scheduler do
  desc 'Sync all scheduled jobs to Google Cloud'
  task sync: :environment do
    RailsCloudTasks::Scheduler.new.upsert
  end
end
