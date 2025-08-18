class ContractMailer < ApplicationMailer
  def contract_email(lead, contract)
    @lead = lead
    @contract = contract
    
    # Generate and attach PDF
    pdf_data = PdfGeneratorService.generate_contract_pdf(contract)
    attachments["umowa_#{contract.number}.pdf"] = pdf_data
    
    mail(
      to: @lead.email,
      subject: "Umowa #{@contract.number} - Agent OZE",
      template_path: 'contract_mailer',
      template_name: 'contract_email'
    )
  end
end