class LeadMailer < ApplicationMailer
  default from: 'agent.oze@example.com'

  def meeting_confirmation(lead, meeting)
    @lead = lead
    @meeting = meeting
    
    mail(
      to: @lead.email,
      subject: 'Potwierdzenie spotkania - Agent OZE'
    )
  end

  def offer_email(lead, offer)
    @lead = lead
    @offer = offer
    
    if @offer.pdf.attached?
      attachments[@offer.pdf.filename.to_s] = @offer.pdf.download
    end
    
    mail(
      to: @lead.email,
      subject: "Oferta #{@offer.number} - Agent OZE"
    )
  end
end
