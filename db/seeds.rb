# Create admin user
admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.role = 'admin'
end

# Create sales user
sales = User.find_or_create_by!(email: 'sales@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.role = 'sales'
end

# Create sample leads
leads_data = [
  {
    first_name: 'Jan', last_name: 'Kowalski', email: 'jan.kowalski@example.com',
    phone: '+48 123 456 789', address: 'ul. Słoneczna 15, 00-000 Warszawa',
    investment_address: 'ul. Słoneczna 15, 00-000 Warszawa',
    source: 'Facebook', product: 'Piec pelletowy 20kW', status: 'fresh',
    notes: 'Klient zainteresowany ekologicznym ogrzewaniem'
  },
  {
    first_name: 'Anna', last_name: 'Nowak', email: 'anna.nowak@example.com',
    phone: '+48 987 654 321', address: 'ul. Kwiatowa 8, 10-000 Kraków',
    investment_address: 'ul. Kwiatowa 8, 10-000 Kraków',
    source: 'Google Ads', product: 'Piec pelletowy 15kW', status: 'contacted',
    notes: 'Pierwszy kontakt nawiązany, umówić spotkanie'
  },
  {
    first_name: 'Piotr', last_name: 'Wiśniewski', email: 'piotr.wisniewski@example.com',
    phone: '+48 555 777 999', address: 'ul. Lipowa 22, 20-000 Gdańsk',
    investment_address: 'ul. Lipowa 22, 20-000 Gdańsk',
    source: 'Polecenie', product: 'Piec pelletowy 25kW', status: 'meeting',
    notes: 'Spotkanie umówione na przyszły tydzień'
  },
  {
    first_name: 'Maria', last_name: 'Zielińska', email: 'maria.zielinska@example.com',
    phone: '+48 111 222 333', address: 'ul. Różana 5, 30-000 Wrocław',
    investment_address: 'ul. Różana 5, 30-000 Wrocław',
    source: 'Targi', product: 'Piec pelletowy 18kW', status: 'offer',
    notes: 'Oferta wysłana, oczekiwanie na decyzję'
  },
  {
    first_name: 'Tomasz', last_name: 'Kaczmarek', email: 'tomasz.kaczmarek@example.com',
    phone: '+48 444 555 666', address: 'ul. Polna 12, 40-000 Poznań',
    investment_address: 'ul. Polna 12, 40-000 Poznań',
    source: 'Strona www', product: 'Piec pelletowy 22kW', status: 'won',
    notes: 'Kontrakt podpisany, gratulacje!'
  },
  {
    first_name: 'Katarzyna', last_name: 'Lewandowska', email: 'katarzyna.lewandowska@example.com',
    phone: '+48 777 888 999', address: 'ul. Leśna 30, 50-000 Łódź',
    investment_address: 'ul. Leśna 30, 50-000 Łódź',
    source: 'Facebook', product: 'Piec pelletowy 16kW', status: 'lost',
    notes: 'Klient wybrał konkurencję', lost_reason: 'Cena zbyt wysoka'
  }
]

leads_data.each do |lead_data|
  Lead.find_or_create_by!(email: lead_data[:email]) do |lead|
    lead.assign_attributes(lead_data)
  end
end

puts "Utworzono #{User.count} użytkowników i #{Lead.count} leadów"

# Create sample meetings
lead_with_meeting = Lead.find_by(status: 'meeting')
if lead_with_meeting && lead_with_meeting.meetings.empty?
  lead_with_meeting.meetings.create!(
    scheduled_at: 1.week.from_now,
    location: 'Dom klienta',
    notes: 'Pomiary i wycena'
  )
end

# Create sample offer
lead_with_offer = Lead.find_by(status: 'offer')
if lead_with_offer && lead_with_offer.offers.empty?
  offer = lead_with_offer.offers.create!(
    description: 'Oferta na piec pelletowy z montażem',
    currency: 'PLN',
    status: 'sent',
    sent_at: 2.days.ago,
    total_cents: 0
  )
  
  offer.offer_items.create!([
    { name: 'Piec pelletowy 18kW', qty: 1, unit_price_cents: 1500000 },
    { name: 'Montaż', qty: 1, unit_price_cents: 200000 },
    { name: 'Komin stalowy', qty: 1, unit_price_cents: 150000 }
  ])
end

puts "Dane seed zostały załadowane pomyślnie!"
