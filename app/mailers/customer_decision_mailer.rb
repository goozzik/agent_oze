class CustomerDecisionMailer < ApplicationMailer
  def decision_confirmed(offer, decision_type)
    @offer = offer
    @lead = offer.lead
    @decision_type = decision_type
    
    mail(
      to: @lead.email,
      subject: decision_subject(decision_type),
      template_path: 'customer_decision_mailer',
      template_name: 'decision_confirmed'
    )
  end

  def internal_notification(offer, decision_type)
    @offer = offer
    @lead = offer.lead
    @decision_type = decision_type
    
    # Send to all admin users
    admin_emails = User.where(role: 'admin').pluck(:email)
    
    mail(
      to: admin_emails,
      subject: "Decyzja klienta: #{decision_type.upcase} - Oferta #{offer.number}",
      template_path: 'customer_decision_mailer',
      template_name: 'internal_notification'
    )
  end

  private

  def decision_subject(decision_type)
    case decision_type
    when 'yes'
      "Potwierdzenie decyzji - Agent OZE"
    when 'no'
      "Dziękujemy za rozważenie naszej oferty - Agent OZE"
    when 'maybe'
      "Skontaktujemy się ponownie - Agent OZE"
    else
      "Potwierdzenie odpowiedzi - Agent OZE"
    end
  end
end