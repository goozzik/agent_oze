class PdfGeneratorService
  include ActionView::Helpers::NumberHelper
  
  def self.generate_offer_pdf(offer)
    new.generate_offer_pdf(offer)
  end
  
  def self.generate_contract_pdf(contract)
    new.generate_contract_pdf(contract)
  end
  
  def generate_offer_pdf(offer)
    html = ApplicationController.render(
      template: 'offers/pdf',
      assigns: { offer: offer, lead: offer.lead },
      layout: 'pdf'
    )
    
    pdf = WickedPdf.new.pdf_from_string(
      html,
      page_size: 'A4',
      margin_top: '0.5in',
      margin_bottom: '0.5in',
      margin_left: '0.5in',
      margin_right: '0.5in',
      encoding: 'UTF-8'
    )
    
    # Optionally attach PDF to offer for caching
    begin
      offer.pdf.attach(
        io: StringIO.new(pdf),
        filename: "oferta_#{offer.number}.pdf",
        content_type: 'application/pdf'
      )
    rescue => e
      Rails.logger.warn "Failed to attach PDF to offer: #{e.message}"
      # Continue anyway, just return the PDF data
    end
    
    pdf
  end
  
  def generate_contract_pdf(contract)
    html = ApplicationController.render(
      template: 'contracts/pdf',
      assigns: { contract: contract, lead: contract.lead },
      layout: 'pdf'
    )
    
    pdf = WickedPdf.new.pdf_from_string(
      html,
      page_size: 'A4',
      margin_top: '0.5in',
      margin_bottom: '0.5in',
      margin_left: '0.5in',
      margin_right: '0.5in',
      encoding: 'UTF-8'
    )
    
    # Attach PDF to contract
    contract.pdf.attach(
      io: StringIO.new(pdf),
      filename: "umowa_#{contract.number}.pdf",
      content_type: 'application/pdf'
    )
    
    pdf
  end
  
  private
  
  def params_show_html?
    # Helper method to show HTML instead of PDF in development
    false
  end
end