class OffersController < ApplicationController
  before_action :set_lead, except: [:index]
  before_action :set_offer, only: [:show, :edit, :update, :destroy, :send_offer, :download_pdf, :customer_decision, :customer_decisions]

  def index
    authorize Offer
    @offers = policy_scope(Offer).includes(:lead).order(created_at: :desc)
  end

  def show
    authorize @offer
  end

  def new
    @offer = @lead.offers.build
    @offer.offer_items.build # Add one empty item to start
    authorize @offer
  end

  def create
    @offer = @lead.offers.build(offer_params)
    @offer.currency = 'PLN'
    authorize @offer

    if @offer.save
      redirect_to [@lead, @offer], notice: 'Oferta została utworzona.'
    else
      @offer.offer_items.build if @offer.offer_items.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @offer
    @offer.offer_items.build if @offer.offer_items.empty?
  end

  def update
    authorize @offer

    if @offer.update(offer_params)
      redirect_to [@lead, @offer], notice: 'Oferta została zaktualizowana.'
    else
      @offer.offer_items.build if @offer.offer_items.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @offer
    @offer.destroy
    redirect_to @lead, notice: 'Oferta została usunięta.'
  end

  def send_offer
    authorize @offer
    
    if @offer.draft?
      # Generate PDF before sending email
      begin
        PdfGeneratorService.generate_offer_pdf(@offer)
        
        @offer.update!(status: 'sent', sent_at: Time.current)
        @lead.update!(status: 'offer')
        
        LeadMailer.offer_email(@lead, @offer).deliver_now
        
        redirect_to [@lead, @offer], notice: 'Oferta została wysłana do klienta z załącznikiem PDF.'
      rescue => e
        Rails.logger.error "Failed to generate PDF for offer #{@offer.id}: #{e.message}"
        redirect_to [@lead, @offer], alert: 'Nie udało się wygenerować PDF. Sprawdź konfigurację systemu.'
      end
    else
      redirect_to [@lead, @offer], alert: 'Oferta już została wysłana.'
    end
  end

  def download_pdf
    authorize @offer
    
    begin
      # Generate PDF if not exists or regenerate
      pdf_data = PdfGeneratorService.generate_offer_pdf(@offer)
      
      send_data pdf_data,
                filename: "oferta_#{@offer.number}.pdf",
                type: 'application/pdf',
                disposition: 'inline'
    rescue => e
      Rails.logger.error "PDF generation failed: #{e.message}"
      redirect_to [@lead, @offer], alert: 'Nie udało się wygenerować PDF. Spróbuj ponownie.'
    end
  end

  def customer_decision
    # Public page for customer decision - no authentication required
    @lead = @offer.lead
    
    unless @offer.can_make_decision?
      if @offer.decision_made?
        # If decision was already made, show the decision page anyway (not an error)
        render layout: false
        return
      else
        redirect_to root_path, alert: 'Oferta nie jest dostępna.'
        return
      end
    end
    
    render layout: false
  end

  def customer_decisions
    # Handle customer decision submission
    decision = params[:decision]
    notes = params[:customer_response]

    unless @offer.can_make_decision?
      # If decision was already made, just redirect back without error
      redirect_to customer_decision_offer_path(@offer)
      return
    end

    case decision
    when 'yes'
      handle_yes_decision(notes)
    when 'no'
      handle_no_decision(notes)
    when 'maybe'
      handle_maybe_decision(notes)
    else
      redirect_to customer_decision_offer_path(@offer), alert: 'Wybierz jedną z opcji.'
      return
    end

    # Show the same page but now with decision made confirmation
    redirect_to customer_decision_offer_path(@offer)
  end

  private

  def set_lead
    @lead = Lead.find(params[:lead_id]) if params[:lead_id]
  end

  def set_offer
    if @lead
      @offer = @lead.offers.find(params[:id])
    else
      @offer = Offer.find(params[:id])
      @lead = @offer.lead
    end
  end

  def offer_params
    params.require(:offer).permit(:description, :delivery_time, :warranty, :bonuses,
      offer_items_attributes: [:id, :name, :qty, :unit_price, :_destroy])
  end

  def handle_yes_decision(notes)
    @offer.update!(
      decision_status: 'customer_yes',
      decision_made_at: Time.current,
      customer_response: notes,
      status: 'accepted'
    )
    
    @offer.lead.update!(status: 'won')
    
    CustomerDecisionMailer.decision_confirmed(@offer, 'yes').deliver_now
    CustomerDecisionMailer.internal_notification(@offer, 'yes').deliver_now
  end

  def handle_no_decision(notes)
    @offer.update!(
      decision_status: 'customer_no',
      decision_made_at: Time.current,
      customer_response: notes,
      status: 'rejected'
    )
    
    @offer.lead.update!(status: 'lost')
    
    CustomerDecisionMailer.decision_confirmed(@offer, 'no').deliver_now
    CustomerDecisionMailer.internal_notification(@offer, 'no').deliver_now
  end

  def handle_maybe_decision(notes)
    @offer.update!(
      decision_status: 'customer_maybe',
      decision_made_at: Time.current,
      customer_response: notes
    )
    
    @offer.lead.update!(status: 'followup')
    
    # Schedule follow-up job for 7 days later
    FollowUpJob.set(wait: 7.days).perform_later(@offer.id)
    
    CustomerDecisionMailer.decision_confirmed(@offer, 'maybe').deliver_now
    CustomerDecisionMailer.internal_notification(@offer, 'maybe').deliver_now
  end
end
