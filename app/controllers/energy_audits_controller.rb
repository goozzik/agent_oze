class EnergyAuditsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_lead
  before_action :set_energy_audit, only: [:show, :edit, :update, :destroy, :download_pdf]
  
  def new
    @energy_audit = @lead.energy_audits.build
    authorize @energy_audit
  end

  def create
    @energy_audit = @lead.energy_audits.build(energy_audit_params)
    authorize @energy_audit
    
    if @energy_audit.save
      # Generate the audit report automatically
      @energy_audit.generate_audit_report
      redirect_to [@lead, @energy_audit], notice: 'Audyt energetyczny został utworzony i przeanalizowany.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @energy_audit
    @audit_report = JSON.parse(@energy_audit.audit_results) if @energy_audit.audit_results
    @professional_calcs = get_professional_calculations(@audit_report) if @audit_report
    @investment_scenarios = get_investment_scenarios(@audit_report) if @audit_report
  end

  def edit
    authorize @energy_audit
  end

  def update
    authorize @energy_audit
    
    if @energy_audit.update(energy_audit_params)
      # Regenerate the audit report with new data
      @energy_audit.generate_audit_report
      redirect_to [@lead, @energy_audit], notice: 'Audyt energetyczny został zaktualizowany.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @energy_audit
    @energy_audit.destroy
    redirect_to @lead, notice: 'Audyt energetyczny został usunięty.'
  end

  def download_pdf
    authorize @energy_audit
    @audit_report = JSON.parse(@energy_audit.audit_results) if @energy_audit.audit_results

    respond_to do |format|
      format.pdf do
        html_content = generate_pdf_html
        
        pdf = WickedPdf.new.pdf_from_string(
          html_content,
          page_size: 'A4',
          margin: {
            top: 20,
            bottom: 20,
            left: 20,
            right: 20
          },
          print_media_type: true,
          footer: {
            right: '[page] / [topage]',
            font_size: 8
          }
        )
        
        filename = "audyt_energetyczny_#{@lead.full_name.parameterize}_#{@energy_audit.created_at.strftime('%Y%m%d')}.pdf"
        send_data pdf, filename: filename, type: 'application/pdf', disposition: 'attachment'
      end
    end
  end
  
  private
  
  def format_number(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse.strip
  end
  
  def get_professional_calculations(audit_report)
    return nil unless audit_report['professional_calculations']
    
    {
      et: format_professional_value(audit_report['professional_calculations']['et']),
      ec: format_professional_value(audit_report['professional_calculations']['ec']),
      ep: format_professional_value(audit_report['professional_calculations']['ep'])
    }
  end
  
  def format_professional_value(value)
    return 'N/A' if value.nil?
    return 'N/A' unless value.is_a?(Numeric) || (value.is_a?(String) && value.match(/\A\d+\.?\d*\z/))
    
    num_value = value.is_a?(String) ? value.to_f : value
    num_value.round(1)
  end
  
  def get_investment_scenarios(audit_report)
    return nil unless audit_report['investment_scenarios']
    
    scenarios = audit_report['investment_scenarios']
    return nil unless scenarios['before'] && scenarios['after_heating']
    
    {
      before: {
        ep: format_professional_value(scenarios['before']['ep']),
        ec: format_professional_value(scenarios['before']['ec']),
        energy_class: scenarios['before']['energy_class'],
        system_efficiency: format_efficiency_percentage(scenarios['before']['system_efficiency'])
      },
      after: {
        ep: format_professional_value(scenarios['after_heating']['ep']),
        ec: format_professional_value(scenarios['after_heating']['ec']),
        energy_class: scenarios['after_heating']['energy_class'],
        system_efficiency: format_efficiency_percentage(scenarios['after_heating']['system_efficiency'])
      },
      savings: scenarios['savings'] ? {
        ep_reduction: format_professional_value(scenarios['savings']['ep_reduction']),
        ec_reduction: format_professional_value(scenarios['savings']['ec_reduction']),
        percentage_savings: scenarios['savings']['percentage_savings']
      } : nil
    }
  end
  
  def format_efficiency_percentage(value)
    return 'N/A' if value.nil?
    return 'N/A' unless value.is_a?(Numeric) || (value.is_a?(String) && value.match(/\A\d+\.?\d*\z/))
    
    num_value = value.is_a?(String) ? value.to_f : value
    (num_value * 100).round(1)
  end
  
  def set_lead
    @lead = Lead.find(params[:lead_id])
  end
  
  def set_energy_audit
    @energy_audit = @lead.energy_audits.find(params[:id])
  end
  
  def energy_audit_params
    params.require(:energy_audit).permit(
      :construction_year, :usable_area, :building_registry_number,
      :current_heat_source, :house_condition, :ventilation_type,
      :insulation_info, :roof_info, :attic_info, :planned_investments,
      :current_energy_consumption, :location_info, :expansion_plans,
      # Advanced building physics fields
      :wall_u_value, :window_u_value, :roof_u_value, :floor_u_value,
      :building_volume, :glazed_area_percentage, :air_tightness_n50,
      :ventilation_heat_recovery_efficiency, :climate_zone,
      # Heating system fields
      :current_system_efficiency, :proposed_system_type, :proposed_system_efficiency,
      :fuel_type_current, :fuel_type_proposed, :primary_energy_factor_current,
      :primary_energy_factor_proposed
    )
  end
  
  def generate_pdf_html
    <<~HTML
      <div style="font-family: Arial, sans-serif; line-height: 1.4; color: #333;">
        <!-- Header -->
        <div style="text-align: center; border-bottom: 2px solid #2563eb; padding-bottom: 20px; margin-bottom: 30px;">
          <h1 style="color: #2563eb; margin: 0; font-size: 24px;">
            🔧 AUDYT ENERGETYCZNY BUDYNKU
          </h1>
          <p style="margin: 5px 0; color: #666; font-size: 14px;">
            Analiza efektywności energetycznej i rekomendacje modernizacyjne
          </p>
          <p style="margin: 5px 0; color: #666; font-size: 12px;">
            Generated by AgentOze • #{Date.current.strftime("%d.%m.%Y")}
          </p>
        </div>

        <!-- Client Information -->
        <div style="margin-bottom: 25px;">
          <h2 style="color: #374151; font-size: 18px; border-bottom: 1px solid #d1d5db; padding-bottom: 5px;">
            👤 Dane klienta
          </h2>
          <table style="width: 100%; margin-top: 10px; font-size: 14px;">
            <tr>
              <td style="padding: 5px 0; width: 30%; font-weight: bold;">Imię i nazwisko:</td>
              <td style="padding: 5px 0;">#{@lead.full_name}</td>
            </tr>
            <tr>
              <td style="padding: 5px 0; font-weight: bold;">Email:</td>
              <td style="padding: 5px 0;">#{@lead.email}</td>
            </tr>
            <tr>
              <td style="padding: 5px 0; font-weight: bold;">Telefon:</td>
              <td style="padding: 5px 0;">#{@lead.phone}</td>
            </tr>
            #{@lead.investment_address.present? ? 
              "<tr>
                <td style='padding: 5px 0; font-weight: bold;'>Adres inwestycji:</td>
                <td style='padding: 5px 0;'>#{@lead.investment_address}</td>
              </tr>" : ""}
          </table>
        </div>

        #{@audit_report ? generate_audit_content : generate_no_audit_content}

        <!-- Footer -->
        <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e7eb; text-align: center; font-size: 12px; color: #6b7280;">
          <p>Raport wygenerowany przez system AgentOze</p>
          <p>Data generowania: #{Date.current.strftime("%d.%m.%Y")} | #{Time.current.strftime("%H:%M")}</p>
          #{@energy_audit.created_at ? "<p>Data audytu: #{@energy_audit.created_at.strftime("%d.%m.%Y %H:%M")}</p>" : ""}
        </div>
      </div>
    HTML
  end

  def generate_audit_content
    energy_class_color = case @energy_audit.energy_class
                         when 'A+', 'A' then 'background-color: #10b981; color: white;'
                         when 'B', 'C' then 'background-color: #f59e0b; color: white;'
                         when 'D', 'E' then 'background-color: #ef4444; color: white;'
                         else 'background-color: #7c3aed; color: white;'
                         end

    clean_air_section = case @energy_audit.current_heat_source
                        when 'coal'
                          <<~HTML
                            <div style="background-color: #dcfce7; border-left: 4px solid #16a34a; padding: 15px; border-radius: 8px;">
                              <h3 style="color: #166534; margin: 0 0 10px 0; font-size: 16px;">✅ Budynek kwalifikuje się do dotacji</h3>
                              <p style="color: #15803d; margin: 0; font-size: 14px;">
                                Budynek z kotłem węglowym kwalifikuje się do dotacji na wymianę źródła ciepła w ramach programu "Czyste Powietrze".
                                Możliwa dotacja do 30 000 zł na wymianę kotła węglowego na piec pelletowy lub pompę ciepła.
                              </p>
                            </div>
                          HTML
                        when 'oil'
                          <<~HTML
                            <div style="background-color: #fef3c7; border-left: 4px solid #d97706; padding: 15px; border-radius: 8px;">
                              <h3 style="color: #d97706; margin: 0 0 10px 0; font-size: 16px;">⚠️ Budynek może kwalifikować się</h3>
                              <p style="color: #b45309; margin: 0; font-size: 14px;">
                                Wymaga dodatkowej weryfikacji wieku kotła i parametrów emisji. 
                                Konieczne sprawdzenie spełnienia kryteriów programu.
                              </p>
                            </div>
                          HTML
                        else
                          <<~HTML
                            <div style="background-color: #f3f4f6; border-left: 4px solid #6b7280; padding: 15px; border-radius: 8px;">
                              <h3 style="color: #6b7280; margin: 0 0 10px 0; font-size: 16px;">ℹ️ Termomodernizacja</h3>
                              <p style="color: #4b5563; margin: 0; font-size: 14px;">
                                Możliwa dotacja na termomodernizację (docieplenie, okna, wentylacja mechaniczna).
                                Program oferuje wsparcie do 37 000 zł na kompleksową modernizację.
                              </p>
                            </div>
                          HTML
                        end

    recommendations_html = @energy_audit.recommendations.split("\n").map do |rec|
      "<div style='margin: 8px 0; font-size: 14px; color: #a16207;'>
        <span style='margin-right: 8px;'>•</span>#{rec}
      </div>"
    end.join

    <<~HTML
      <!-- Energy Class Badge -->
      <div style="text-align: center; margin: 25px 0;">
        <div style="display: inline-block; padding: 15px 30px; #{energy_class_color} border-radius: 8px; font-size: 20px; font-weight: bold;">
          🏠 Klasa Energetyczna: #{@energy_audit.energy_class}
        </div>
      </div>

      <!-- Building Information -->
      <div style="margin-bottom: 25px;">
        <h2 style="color: #374151; font-size: 18px; border-bottom: 1px solid #d1d5db; padding-bottom: 5px;">
          🏗️ Charakterystyka budynku
        </h2>
        <table style="width: 100%; margin-top: 10px; font-size: 14px; border-collapse: collapse;">
          <tr>
            <td style="padding: 8px; background-color: #f9fafb; font-weight: bold; width: 40%; border: 1px solid #e5e7eb;">Rok budowy</td>
            <td style="padding: 8px; border: 1px solid #e5e7eb;">#{@audit_report['building_info']['construction_year']}</td>
          </tr>
          <tr>
            <td style="padding: 8px; background-color: #f9fafb; font-weight: bold; border: 1px solid #e5e7eb;">Powierzchnia użytkowa</td>
            <td style="padding: 8px; border: 1px solid #e5e7eb;">#{@audit_report['building_info']['usable_area']} m²</td>
          </tr>
          <tr>
            <td style="padding: 8px; background-color: #f9fafb; font-weight: bold; border: 1px solid #e5e7eb;">Obecne źródło ciepła</td>
            <td style="padding: 8px; border: 1px solid #e5e7eb;">#{@audit_report['building_info']['current_heat_source']}</td>
          </tr>
          <tr>
            <td style="padding: 8px; background-color: #f9fafb; font-weight: bold; border: 1px solid #e5e7eb;">Stan budynku</td>
            <td style="padding: 8px; border: 1px solid #e5e7eb;">#{@audit_report['building_info']['house_condition']}</td>
          </tr>
          <tr>
            <td style="padding: 8px; background-color: #f9fafb; font-weight: bold; border: 1px solid #e5e7eb;">Typ wentylacji</td>
            <td style="padding: 8px; border: 1px solid #e5e7eb;">#{@audit_report['building_info']['ventilation_type']}</td>
          </tr>
        </table>
      </div>

      <!-- Energy Analysis -->
      <div style="margin-bottom: 25px;">
        <h2 style="color: #374151; font-size: 18px; border-bottom: 1px solid #d1d5db; padding-bottom: 5px;">
          ⚡ Analiza energetyczna
        </h2>
        
        <table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
          <tr>
            <td style="text-align: center; padding: 15px; background-color: #dbeafe; border-radius: 8px; width: 33%;">
              <div style="font-size: 24px; font-weight: bold; color: #1e40af;">
                #{format_number(@audit_report['energy_analysis']['annual_demand'])}
              </div>
              <div style="font-size: 12px; color: #3730a3;">kWh/rok</div>
              <div style="font-size: 10px; color: #4338ca; margin-top: 5px;">Zapotrzebowanie roczne</div>
            </td>
            <td style="text-align: center; padding: 15px; background-color: #dcfce7; border-radius: 8px; width: 33%;">
              <div style="font-size: 24px; font-weight: bold; color: #166534;">
                #{@audit_report['energy_analysis']['demand_per_m2']}
              </div>
              <div style="font-size: 12px; color: #15803d;">kWh/m²/rok</div>
              <div style="font-size: 10px; color: #16a34a; margin-top: 5px;">Na metr kwadratowy</div>
            </td>
            <td style="text-align: center; padding: 15px; background-color: #fae8ff; border-radius: 8px; width: 33%;">
              <div style="font-size: 24px; font-weight: bold; color: #7c3aed;">
                #{@energy_audit.energy_class}
              </div>
              <div style="font-size: 12px; color: #8b5cf6;">Klasa</div>
              <div style="font-size: 10px; color: #a855f7; margin-top: 5px;">Energetyczna</div>
            </td>
          </tr>
        </table>
      </div>

      #{@audit_report['professional_calculations'] ? generate_professional_calculations_section : ''}

      #{(@audit_report['investment_scenarios'] && @audit_report['investment_scenarios']['after_heating']) ? generate_investment_scenarios_section : ''}

      #{(@audit_report['cost_analysis'] && @audit_report['cost_analysis']['proposed']) ? generate_cost_analysis_section : ''}

      <!-- Clean Air Program -->
      <div style="margin-bottom: 25px;">
        <h2 style="color: #374151; font-size: 18px; border-bottom: 1px solid #d1d5db; padding-bottom: 5px;">
          🌱 Program "Czyste Powietrze"
        </h2>
        <div style="margin-top: 15px;">
          #{clean_air_section}
        </div>
      </div>

      <!-- Recommendations -->
      <div style="margin-bottom: 25px;">
        <h2 style="color: #374151; font-size: 18px; border-bottom: 1px solid #d1d5db; padding-bottom: 5px;">
          💡 Rekomendacje modernizacyjne
        </h2>
        
        <div style="background-color: #fefce8; padding: 15px; border-radius: 8px; border-left: 4px solid #eab308; margin-top: 15px;">
          #{recommendations_html}
        </div>
      </div>
    HTML
  end

  def generate_no_audit_content
    <<~HTML
      <div style="background-color: #fef3c7; padding: 20px; border-radius: 8px; border-left: 4px solid #d97706;">
        <h3 style="color: #d97706; margin: 0 0 10px 0;">⚠️ Audyt nie został przeanalizowany</h3>
        <p style="color: #b45309; margin: 0;">
          Raport nie zawiera analizy energetycznej. Skontaktuj się w celu wygenerowania pełnego audytu.
        </p>
      </div>
    HTML
  end

  def generate_professional_calculations_section
    <<~HTML
      <div style="margin-bottom: 25px;">
        <h2 style="color: #374151; font-size: 18px; border-bottom: 1px solid #d1d5db; padding-bottom: 5px;">
          🎯 Profesjonalne kalkulacje energetyczne (EP/EC/ET)
        </h2>
        
        <table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
          <tr>
            <td style="text-align: center; padding: 15px; background-color: #fee2e2; border-radius: 8px; width: 33%;">
              <div style="font-size: 20px; font-weight: bold; color: #dc2626;">
                #{(@audit_report['professional_calculations']['et'] || 0).round(1)}
              </div>
              <div style="font-size: 12px; color: #b91c1c;">kWh/m²/rok</div>
              <div style="font-size: 10px; color: #991b1b; margin-top: 5px;">ET - Straty transmisji</div>
            </td>
            <td style="text-align: center; padding: 15px; background-color: #fed7aa; border-radius: 8px; width: 33%;">
              <div style="font-size: 20px; font-weight: bold; color: #ea580c;">
                #{(@audit_report['professional_calculations']['ec'] || 0).round(1)}
              </div>
              <div style="font-size: 12px; color: #c2410c;">kWh/m²/rok</div>
              <div style="font-size: 10px; color: #9a3412; margin-top: 5px;">EC - Energia końcowa</div>
            </td>
            <td style="text-align: center; padding: 15px; background-color: #e9d5ff; border-radius: 8px; width: 33%;">
              <div style="font-size: 20px; font-weight: bold; color: #7c3aed;">
                #{(@audit_report['professional_calculations']['ep'] || 0).round(1)}
              </div>
              <div style="font-size: 12px; color: #8b5cf6;">kWh/m²/rok</div>
              <div style="font-size: 10px; color: #a855f7; margin-top: 5px;">EP - Energia pierwotna</div>
            </td>
          </tr>
        </table>
        
        <div style="background-color: #f3f4f6; padding: 12px; border-radius: 6px; font-size: 11px; color: #4b5563;">
          <strong>Wyjaśnienie wskaźników:</strong><br>
          • ET - Wskaźnik strat na transmisję przez przegrody budowlane<br>
          • EC - Zapotrzebowanie na energię końcową dostarczaną do budynku<br>  
          • EP - Zapotrzebowanie na energię pierwotną (uwzględnia straty wytwarzania i przesyłu)
        </div>
      </div>
    HTML
  end

  def generate_investment_scenarios_section
    <<~HTML
      <div style="margin-bottom: 25px;">
        <h2 style="color: #374151; font-size: 18px; border-bottom: 1px solid #d1d5db; padding-bottom: 5px;">
          📊 Porównanie przed/po modernizacji
        </h2>
        
        <table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
          <tr>
            <td style="width: 48%; vertical-align: top; padding-right: 2%;">
              <div style="background-color: #fef2f2; padding: 15px; border-radius: 8px; border-left: 4px solid #ef4444;">
                <h3 style="color: #dc2626; margin: 0 0 10px 0; font-size: 14px;">🔴 PRZED modernizacją</h3>
                <div style="font-size: 12px; line-height: 1.8;">
                  <div style="display: flex; justify-content: space-between;">
                    <span>EP:</span>
                    <strong>#{(@audit_report['investment_scenarios']['before']['ep'] || 0).round(1)} kWh/m²/rok</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>EC:</span>
                    <strong>#{(@audit_report['investment_scenarios']['before']['ec'] || 0).round(1)} kWh/m²/rok</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>Klasa energetyczna:</span>
                    <strong style="color: #dc2626;">#{@audit_report['investment_scenarios']['before']['energy_class']}</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>Sprawność systemu:</span>
                    <strong>#{(@audit_report['investment_scenarios']['before']['system_efficiency'] * 100).round(1)}%</strong>
                  </div>
                </div>
              </div>
            </td>
            <td style="width: 48%; vertical-align: top; padding-left: 2%;">
              <div style="background-color: #f0fdf4; padding: 15px; border-radius: 8px; border-left: 4px solid #22c55e;">
                <h3 style="color: #16a34a; margin: 0 0 10px 0; font-size: 14px;">🟢 PO modernizacji</h3>
                <div style="font-size: 12px; line-height: 1.8;">
                  <div style="display: flex; justify-content: space-between;">
                    <span>EP:</span>
                    <strong>#{(@audit_report['investment_scenarios']['after_heating']['ep'] || 0).round(1)} kWh/m²/rok</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>EC:</span>
                    <strong>#{(@audit_report['investment_scenarios']['after_heating']['ec'] || 0).round(1)} kWh/m²/rok</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>Klasa energetyczna:</span>
                    <strong style="color: #16a34a;">#{@audit_report['investment_scenarios']['after_heating']['energy_class']}</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>Sprawność systemu:</span>
                    <strong>#{(@audit_report['investment_scenarios']['after_heating']['system_efficiency'] * 100).round(1)}%</strong>
                  </div>
                </div>
              </div>
            </td>
          </tr>
        </table>
        
        #{@audit_report['investment_scenarios']['savings'] ? 
          "<div style='background-color: #ecfdf5; padding: 15px; border-radius: 8px; margin-top: 15px;'>
            <h4 style='color: #16a34a; margin: 0 0 10px 0; font-size: 14px;'>💰 Oszczędności energetyczne</h4>
            <table style='width: 100%; border-collapse: collapse;'>
              <tr>
                <td style='text-align: center; padding: 10px;'>
                  <div style='font-size: 18px; font-weight: bold; color: #166534;'>#{(@audit_report['investment_scenarios']['savings']['ep_reduction'] || 0).round(1)}</div>
                  <div style='font-size: 10px; color: #15803d;'>kWh/m²/rok EP</div>
                </td>
                <td style='text-align: center; padding: 10px;'>
                  <div style='font-size: 18px; font-weight: bold; color: #166534;'>#{(@audit_report['investment_scenarios']['savings']['ec_reduction'] || 0).round(1)}</div>
                  <div style='font-size: 10px; color: #15803d;'>kWh/m²/rok EC</div>
                </td>
                <td style='text-align: center; padding: 10px;'>
                  <div style='font-size: 18px; font-weight: bold; color: #166534;'>#{@audit_report['investment_scenarios']['savings']['percentage_savings']}%</div>
                  <div style='font-size: 10px; color: #15803d;'>Redukcja EP</div>
                </td>
              </tr>
            </table>
          </div>" : ''
        }
      </div>
    HTML
  end

  def generate_cost_analysis_section
    <<~HTML
      <div style="margin-bottom: 25px;">
        <h2 style="color: #374151; font-size: 18px; border-bottom: 1px solid #d1d5db; padding-bottom: 5px;">
          💵 Analiza kosztów i zwrotu inwestycji
        </h2>
        
        <table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
          <tr>
            <td style="width: 48%; vertical-align: top; padding-right: 2%;">
              <div style="background-color: #fef2f2; padding: 15px; border-radius: 8px;">
                <h3 style="color: #374151; margin: 0 0 10px 0; font-size: 14px;">Obecne koszty roczne</h3>
                <div style="font-size: 12px; line-height: 1.8;">
                  <div style="display: flex; justify-content: space-between;">
                    <span>Zużycie:</span>
                    <strong>#{format_number(@audit_report['cost_analysis']['current']['annual_consumption_kwh'])} kWh/rok</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>Paliwo:</span>
                    <strong>#{@audit_report['cost_analysis']['current']['fuel_type'].capitalize}</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between; font-size: 14px; margin-top: 8px;">
                    <span>Koszt roczny:</span>
                    <strong style="color: #dc2626;">#{format_number(@audit_report['cost_analysis']['current']['annual_cost'])} PLN</strong>
                  </div>
                </div>
              </div>
            </td>
            <td style="width: 48%; vertical-align: top; padding-left: 2%;">
              <div style="background-color: #f0fdf4; padding: 15px; border-radius: 8px;">
                <h3 style="color: #374151; margin: 0 0 10px 0; font-size: 14px;">Po modernizacji</h3>
                <div style="font-size: 12px; line-height: 1.8;">
                  <div style="display: flex; justify-content: space-between;">
                    <span>Zużycie:</span>
                    <strong>#{format_number(@audit_report['cost_analysis']['proposed']['annual_consumption_kwh'])} kWh/rok</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>Paliwo:</span>
                    <strong>#{@audit_report['cost_analysis']['proposed']['fuel_type'].capitalize}</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between; font-size: 14px; margin-top: 8px;">
                    <span>Koszt roczny:</span>
                    <strong style="color: #16a34a;">#{format_number(@audit_report['cost_analysis']['proposed']['annual_cost'])} PLN</strong>
                  </div>
                </div>
              </div>
            </td>
          </tr>
        </table>
        
        #{@audit_report['cost_analysis']['savings'] ? 
          "<div style='background-color: #ecfdf5; padding: 15px; border-radius: 8px; margin-top: 15px;'>
            <h4 style='color: #16a34a; margin: 0 0 10px 0; font-size: 14px;'>🎯 Zwrot z inwestycji</h4>
            <table style='width: 100%; border-collapse: collapse;'>
              <tr>
                <td style='text-align: center; padding: 8px; width: 25%;'>
                  <div style='font-size: 16px; font-weight: bold; color: #166534;'>#{format_number(@audit_report['cost_analysis']['savings']['annual_savings_pln'])} PLN</div>
                  <div style='font-size: 9px; color: #15803d;'>Oszczędność/rok</div>
                </td>
                <td style='text-align: center; padding: 8px; width: 25%;'>
                  <div style='font-size: 16px; font-weight: bold; color: #166534;'>#{@audit_report['cost_analysis']['savings']['percentage_savings']}%</div>
                  <div style='font-size: 9px; color: #15803d;'>Redukcja kosztów</div>
                </td>
                <td style='text-align: center; padding: 8px; width: 25%;'>
                  <div style='font-size: 16px; font-weight: bold; color: #1d4ed8;'>#{@audit_report['cost_analysis']['investment'] ? @audit_report['cost_analysis']['investment']['payback_period_years'] : 'N/A'}</div>
                  <div style='font-size: 9px; color: #1e40af;'>Lat zwrotu</div>
                </td>
                <td style='text-align: center; padding: 8px; width: 25%;'>
                  <div style='font-size: 16px; font-weight: bold; color: #7c3aed;'>#{@audit_report['cost_analysis']['investment'] ? format_number(@audit_report['cost_analysis']['investment']['lifetime_savings_20_years']) : 'N/A'} PLN</div>
                  <div style='font-size: 9px; color: #8b5cf6;'>Zysk 20 lat</div>
                </td>
              </tr>
            </table>
          </div>" : ''
        }
      </div>
    HTML
  end
end
