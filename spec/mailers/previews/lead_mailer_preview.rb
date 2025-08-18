# Preview all emails at http://localhost:3000/rails/mailers/lead_mailer_mailer
class LeadMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/lead_mailer_mailer/meeting_confirmation
  def meeting_confirmation
    LeadMailer.meeting_confirmation
  end

  # Preview this email at http://localhost:3000/rails/mailers/lead_mailer_mailer/offer_email
  def offer_email
    LeadMailer.offer_email
  end

end
