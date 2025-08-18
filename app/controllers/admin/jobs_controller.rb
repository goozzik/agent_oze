class Admin::JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @jobs = SolidQueue::Job.order(created_at: :desc).limit(50)
    @pending_jobs = SolidQueue::Job.where(finished_at: nil).count
    @scheduled_jobs = SolidQueue::Job.where.not(scheduled_at: nil).where(finished_at: nil).count
    @failed_jobs = SolidQueue::FailedExecution.count
  end

  def show
    @job = SolidQueue::Job.find(params[:id])
    @failed_execution = SolidQueue::FailedExecution.find_by(job_id: @job.id)
  end

  private

  def ensure_admin
    redirect_to root_path unless current_user.admin?
  end
end
