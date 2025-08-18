class LeadsController < ApplicationController
  before_action :set_lead, only: [:show, :edit, :update, :destroy, :update_status]

  def index
    authorize Lead
    @leads = policy_scope(Lead)
    @leads = @leads.by_status(params[:status]) if params[:status].present?
    @leads = @leads.by_source(params[:source]) if params[:source].present?
    @leads = @leads.order(created_at: :desc)
  end

  def show
    authorize @lead
  end

  def new
    @lead = Lead.new
    authorize @lead
  end

  def create
    @lead = Lead.new(lead_params)
    authorize @lead

    if @lead.save
      redirect_to @lead, notice: 'Lead został pomyślnie utworzony.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @lead
  end

  def update
    authorize @lead

    if @lead.update(lead_params)
      redirect_to @lead, notice: 'Lead został zaktualizowany.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @lead
    @lead.destroy
    redirect_to leads_url, notice: 'Lead został usunięty.'
  end

  def update_status
    authorize @lead
    
    if @lead.update(status: params[:status])
      redirect_to @lead, notice: "Status został zmieniony na #{@lead.status}."
    else
      redirect_to @lead, alert: 'Nie udało się zmienić statusu.'
    end
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:first_name, :last_name, :phone, :email, :address, 
                                 :investment_address, :source, :product, :notes, 
                                 :lost_reason, photos: [])
  end
end
