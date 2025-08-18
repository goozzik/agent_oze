class MeetingsController < ApplicationController
  before_action :set_lead
  before_action :set_meeting, only: [:show, :edit, :update, :destroy]

  def new
    @meeting = @lead.meetings.build
  end

  def create
    @meeting = @lead.meetings.build(meeting_params)

    if @meeting.save
      # Update lead status to meeting
      @lead.update!(status: 'meeting')
      
      # Send confirmation email
      LeadMailer.meeting_confirmation(@lead, @meeting).deliver_now
      
      redirect_to @lead, notice: 'Spotkanie zostało umówione i wysłano potwierdzenie e-mailem.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @meeting.update(meeting_params)
      redirect_to @lead, notice: 'Spotkanie zostało zaktualizowane.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meeting.destroy
    redirect_to @lead, notice: 'Spotkanie zostało usunięte.'
  end

  private

  def set_lead
    @lead = Lead.find(params[:lead_id])
  end

  def set_meeting
    @meeting = @lead.meetings.find(params[:id])
  end

  def meeting_params
    params.require(:meeting).permit(:scheduled_at, :location, :notes)
  end
end
