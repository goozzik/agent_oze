class FollowUpMailer < ApplicationMailer
  default from: 'agent.oze@example.com'

  def remind_decision(offer)
    @offer = offer
    @lead = offer.lead
    
    # Attach additional materials (catalogs, case studies)
    attach_marketing_materials
    
    mail(
      to: @lead.email,
      subject: "Przypomnienie o ofercie #{@offer.number} - dodatkowe materiały w załączniku"
    )
  end

  private

  def attach_marketing_materials
    # Attach catalog PDF if exists
    catalog_path = Rails.root.join('app', 'assets', 'documents', 'katalog_agent_oze.pdf')
    if File.exist?(catalog_path)
      attachments['Katalog_Agent_OZE.pdf'] = File.read(catalog_path)
    end
    
    # Attach case study PDF if exists  
    case_study_path = Rails.root.join('app', 'assets', 'documents', 'case_study_realizacje.pdf')
    if File.exist?(case_study_path)
      attachments['Nasze_Realizacje.pdf'] = File.read(case_study_path)
    end
    
    # Attach technical specifications if exists
    spec_path = Rails.root.join('app', 'assets', 'documents', 'specyfikacja_techniczna.pdf')
    if File.exist?(spec_path)
      attachments['Specyfikacja_Techniczna.pdf'] = File.read(spec_path)
    end
  end
end