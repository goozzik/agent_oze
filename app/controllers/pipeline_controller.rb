class PipelineController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize :pipeline, :index?
    
    @leads = policy_scope(Lead).includes(:user, :offers, :meetings)
    
    @pipeline_data = {
      'fresh' => @leads.where(status: 'fresh').order(:created_at),
      'contacted' => @leads.where(status: 'contacted').order(:updated_at),
      'meeting' => @leads.where(status: 'meeting').order(:updated_at),
      'offer' => @leads.where(status: 'offer').order(:updated_at),
      'negotiation' => @leads.where(status: 'negotiation').order(:updated_at),
      'won' => @leads.where(status: 'won').order(:updated_at),
      'lost' => @leads.where(status: 'lost').order(:updated_at),
      'followup' => @leads.where(status: 'followup').order(:updated_at)
    }
    
    @total_value = {
      'offer' => calculate_pipeline_value('offer'),
      'negotiation' => calculate_pipeline_value('negotiation'),
      'won' => calculate_pipeline_value('won')
    }
  end

  def update_status
    @lead = Lead.find(params[:id])
    authorize @lead, :update?
    
    old_status = @lead.status
    new_status = params[:status]
    
    if Lead.statuses.keys.include?(new_status)
      @lead.update!(status: new_status)
      
      # Log the status change
      Rails.logger.info "Lead #{@lead.id} moved from #{old_status} to #{new_status} by #{current_user.email}"
      
      render json: { 
        status: 'success', 
        message: "Lead moved to #{new_status.humanize}",
        lead_id: @lead.id,
        old_status: old_status,
        new_status: new_status
      }
    else
      render json: { 
        status: 'error', 
        message: 'Invalid status' 
      }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Failed to update lead status: #{e.message}"
    render json: { 
      status: 'error', 
      message: 'Failed to update status' 
    }, status: :unprocessable_entity
  end

  private

  def calculate_pipeline_value(status)
    leads_in_status = @pipeline_data[status] || []
    leads_in_status.sum do |lead|
      lead.offers.where(status: ['draft', 'sent', 'accepted']).sum do |offer|
        offer.total.cents / 100.0
      end
    end
  end
end