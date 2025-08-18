class CustomerDecisionsController < ApplicationController
  before_action :set_offer
  before_action :check_decision_allowed

  def show
    # Public page for customer to view offer and make decision
    # No authentication required - accessed via secure token
    @lead = @offer.lead
  end

  def create
    decision = params[:decision]
    notes = params[:customer_response]

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

    redirect_to customer_decision_offer_path(@offer), notice: 'Dziękujemy za odpowiedź!'
  end

  private

  def set_offer
    @offer = Offer.find(params[:offer_id] || params[:id])
  end

  def check_decision_allowed
    unless @offer.can_make_decision?
      redirect_to root_path, alert: 'Oferta nie jest dostępna lub decyzja została już podjęta.'
    end
  end

  def handle_yes_decision(notes)
    @offer.update!(
      decision_status: 'customer_yes',
      decision_made_at: Time.current,
      customer_response: notes,
      status: 'accepted'
    )
    
    # Update lead status
    @offer.lead.update!(status: 'won')
    
    # Send confirmation email
    CustomerDecisionMailer.decision_confirmed(@offer, 'yes').deliver_now
    
    # Notify internal team
    CustomerDecisionMailer.internal_notification(@offer, 'yes').deliver_now
  end

  def handle_no_decision(notes)
    @offer.update!(
      decision_status: 'customer_no',
      decision_made_at: Time.current,
      customer_response: notes,
      status: 'rejected'
    )
    
    # Update lead status
    @offer.lead.update!(status: 'lost')
    
    # Send confirmation email
    CustomerDecisionMailer.decision_confirmed(@offer, 'no').deliver_now
    
    # Notify internal team
    CustomerDecisionMailer.internal_notification(@offer, 'no').deliver_now
  end

  def handle_maybe_decision(notes)
    @offer.update!(
      decision_status: 'customer_maybe',
      decision_made_at: Time.current,
      customer_response: notes
    )
    
    # Update lead status to followup
    @offer.lead.update!(status: 'followup')
    
    # Send confirmation email
    CustomerDecisionMailer.decision_confirmed(@offer, 'maybe').deliver_now
    
    # Notify internal team
    CustomerDecisionMailer.internal_notification(@offer, 'maybe').deliver_now
    
    # Schedule follow-up task (could be automated)
    # Task.create!(
    #   lead: @offer.lead,
    #   title: "Follow-up po odpowiedzi 'MOŻE' na ofertę #{@offer.number}",
    #   description: "Klient odpowiedział 'MOŻE' na ofertę. Zaplanuj kontakt.",
    #   due_date: 1.week.from_now,
    #   status: 'pending'
    # )
  end
end