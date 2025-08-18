class ContractsController < ApplicationController
  before_action :set_lead
  before_action :set_contract, only: [:show, :destroy, :download_pdf, :send_contract]

  def show
    authorize @contract
  end

  def new
    @contract = @lead.contracts.build
    # Pre-fill contract data from the latest accepted offer
    @latest_offer = @lead.offers.where(status: 'accepted').last
    authorize @contract
  end

  def create
    @contract = @lead.contracts.build(contract_params)
    authorize @contract

    if @contract.save
      @lead.update!(status: 'won') # Mark lead as won when contract is created
      redirect_to [@lead, @contract], notice: 'Umowa została utworzona.'
    else
      @latest_offer = @lead.offers.where(status: 'accepted').last
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @contract
    @contract.destroy
    redirect_to @lead, notice: 'Umowa została usunięta.'
  end

  def download_pdf
    authorize @contract
    
    begin
      pdf_data = PdfGeneratorService.generate_contract_pdf(@contract)
      
      send_data pdf_data,
                filename: "umowa_#{@contract.number}.pdf",
                type: 'application/pdf',
                disposition: 'inline'
    rescue => e
      Rails.logger.error "Contract PDF generation failed: #{e.message}"
      redirect_to [@lead, @contract], alert: 'Nie udało się wygenerować PDF umowy. Spróbuj ponownie.'
    end
  end

  def send_contract
    authorize @contract
    
    begin
      ContractMailer.contract_email(@lead, @contract).deliver_now
      @contract.update!(sent_at: Time.current)
      
      redirect_to [@lead, @contract], notice: 'Umowa została wysłana do klienta.'
    rescue => e
      Rails.logger.error "Contract email failed: #{e.message}"
      redirect_to [@lead, @contract], alert: 'Nie udało się wysłać umowy. Spróbuj ponownie.'
    end
  end

  private

  def set_lead
    @lead = Lead.find(params[:lead_id])
  end

  def set_contract
    @contract = @lead.contracts.find(params[:id])
  end

  def contract_params
    params.require(:contract).permit(:description, :terms, :total_amount, :payment_terms,
                                   :delivery_date, :warranty_period, :special_conditions)
  end
end