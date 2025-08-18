class ReportsController < ApplicationController
  before_action :authenticate_user!

  def weekly
    authorize :report, :weekly?
    
    @current_week_start = Date.current.beginning_of_week
    @current_week_end = Date.current.end_of_week
    @previous_week_start = 1.week.ago.beginning_of_week
    @previous_week_end = 1.week.ago.end_of_week
    
    # Current week stats
    @current_week_leads = Lead.where(created_at: @current_week_start..@current_week_end)
    @current_week_offers = Offer.where(created_at: @current_week_start..@current_week_end)
    @current_week_meetings = Meeting.where(scheduled_at: @current_week_start..@current_week_end)
    
    # Previous week stats for comparison
    @previous_week_leads = Lead.where(created_at: @previous_week_start..@previous_week_end)
    @previous_week_offers = Offer.where(created_at: @previous_week_start..@previous_week_end)
    @previous_week_meetings = Meeting.where(scheduled_at: @previous_week_start..@previous_week_end)
    
    # Overall stats
    @total_leads = Lead.count
    @total_offers = Offer.count
    @total_value = Money.new(Offer.sum(:total_cents), 'PLN')
    
    # Conversion rates
    @leads_to_offers_rate = calculate_conversion_rate(@total_leads, @total_offers)
    @offers_sent = Offer.where(status: 'sent').count
    @offers_accepted = Offer.where(status: 'accepted').count
    @offer_acceptance_rate = calculate_conversion_rate(@offers_sent, @offers_accepted)
    
    # Monthly trend data for charts
    @monthly_leads = Lead.group_by_month(:created_at, last: 6).count
    @monthly_offers = Offer.group_by_month(:created_at, last: 6).count
    @monthly_revenue = Offer.where(status: 'accepted')
                            .group_by_month(:created_at, last: 6)
                            .sum(:total_cents)
                            .transform_values { |cents| Money.new(cents, 'PLN') }
  end

  def pipeline
    authorize :report, :pipeline?
    
    @pipeline_stats = {
      fresh: Lead.where(status: 'fresh').count,
      contacted: Lead.where(status: 'contacted').count,
      meeting: Lead.where(status: 'meeting').count,
      offer: Lead.where(status: 'offer').count,
      won: Lead.where(status: 'won').count,
      lost: Lead.where(status: 'lost').count
    }
    
    @leads_by_status = Lead.group(:status).count
    @offers_by_status = Offer.group(:status).count
    
    # Pipeline value (potential revenue)
    @pipeline_value = {
      meeting: Money.new(Lead.joins(:offers).where(status: 'meeting').sum('offers.total_cents'), 'PLN'),
      offer: Money.new(Lead.joins(:offers).where(status: 'offer').sum('offers.total_cents'), 'PLN'),
      won: Money.new(Lead.joins(:offers).where(status: 'won').sum('offers.total_cents'), 'PLN')
    }
    
    @recent_activities = build_recent_activities
  end

  private

  def calculate_conversion_rate(total, converted)
    return 0 if total == 0
    ((converted.to_f / total) * 100).round(1)
  end
  
  def build_recent_activities
    activities = []
    
    # Recent leads
    Lead.includes(:user).order(created_at: :desc).limit(5).each do |lead|
      activities << {
        type: 'lead_created',
        title: "Nowy lead: #{lead.full_name}",
        time: lead.created_at,
        icon: '👤',
        color: 'blue'
      }
    end
    
    # Recent offers
    Offer.includes(:lead).order(created_at: :desc).limit(5).each do |offer|
      activities << {
        type: 'offer_created',
        title: "Oferta #{offer.number} dla #{offer.lead.full_name}",
        time: offer.created_at,
        icon: '📄',
        color: 'green'
      }
    end
    
    # Recent meetings
    Meeting.includes(:lead).order(scheduled_at: :desc).limit(5).each do |meeting|
      activities << {
        type: 'meeting_scheduled',
        title: "Spotkanie z #{meeting.lead.full_name}",
        time: meeting.scheduled_at,
        icon: '📅',
        color: 'purple'
      }
    end
    
    activities.sort_by { |a| a[:time] }.reverse.first(10)
  end
end