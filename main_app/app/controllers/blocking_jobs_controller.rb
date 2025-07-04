class BlockingJobsController < ApplicationController
  def show
    render json: {job: GoodJob::Job.find(params[:id])}
  end
end

