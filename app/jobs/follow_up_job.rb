class FollowUpJob < ApplicationJob
  queue_as :default

  def perform(offer_id)
    offer = Offer.find(offer_id)
    lead = offer.lead
    
    # Check if decision was already made
    return if offer.decision_made?
    
    # Send follow-up email
    FollowUpMailer.remind_decision(offer).deliver_now
    
    # Create follow-up task for sales team
    Task.create!(
      lead: lead,
      kind: 'followup',
      due_at: Time.current,
      done: false
    )
    
    Rails.logger.info "Follow-up job executed for offer #{offer.number}"
  end
end