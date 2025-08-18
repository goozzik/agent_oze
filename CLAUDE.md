# Claude Code - Instrukcje dla AI

## 📝 Kluczowe pliki do aktualizacji

Przy dodawaniu nowych funkcji **ZAWSZE** aktualizuj te pliki:

### 1. **ROADMAP.md** 
- ✅ Oznacz ukończone funkcje jako `completed`
- 🚧 Dodaj nowe funkcje do sekcji "PLANOWANE FUNKCJE"
- 📊 Aktualizuj % postępu MVP
- 🎯 Zaktualizuj "NASTĘPNE KROKI ROZWOJU"

### 2. **README.md**
- ✅ Dodaj nowe funkcje do sekcji "Działające obecnie"
- 📂 Zaktualizuj strukturę projektu jeśli potrzeba
- 🎯 Zaktualizuj flow procesu sprzedaży
- 📈 Zaktualizuj "Metryki sukcesu" i % MVP

### 3. **db/seeds.rb**
- 📊 Dodaj przykładowe dane dla nowych funkcji
- 🧪 Upewnij się że seed data testuje nowe features

## 🛠️ Komendy do zapamiętania

```bash
# Uruchomienie z Tailwind
bin/dev

# Przebudowanie CSS
rails tailwindcss:build

# Reset bazy z seed data
rails db:reset

# Podgląd maili
http://localhost:3000/letter_opener

# Testy (gdy będą gotowe)
bundle exec rspec
```

## 📋 Stan projektu

**Ostatnia aktualizacja:** 17 sierpnia 2025  
**MVP status:** 🟡 75% - podstawowe funkcje działają

### ✅ **Ukończone moduły:**
- Leads CRUD + filtry
- Meetings + email notifications  
- Offers + dynamiczne pozycje
- Mailery z profesjonalnymi szablonami
- Autoryzacja i UI

### 🚧 **Następne priorytety:**
1. **PDF generation** - najważniejsze dla użytkowników
2. **Dashboard/raporty** - monitoring sprzedaży
3. **System decyzji** klienta (YES/NO/MAYBE)
4. **Pomiary i kalkulacje** mocy kotła

## 🏗️ Konwencje projektu

### Nazewnictwo
- **Kontrolery:** `leads_controller.rb`
- **Modele:** `lead.rb` 
- **Widoki:** `leads/index.html.erb`
- **Mailers:** `lead_mailer.rb`
- **Services:** `pdf_generator_service.rb` (planowane)

### Style kodowania
- **Tailwind CSS** dla wszystkich stylów
- **Simple Form** dla formularzy
- **Pundit** dla autoryzacji
- **Money-rails** dla kwot w groszach
- **ActiveStorage** dla plików

### Testy (planowane)
- **RSpec** + **Capybara** dla system tests
- **Factory Bot** dla test data
- Testy integracyjne dla email flow

## 🎯 Cele biznesowe

### Główny flow:
```
Lead → Meeting → Pomiar → Oferta → Decyzja → Kontrakt
```

### Kluczowe metryki:
- Conversion rate lead → meeting
- Conversion rate meeting → oferta  
- Conversion rate oferta → kontrakt
- Średnia wartość kontraktu
- Czas od lead do zamknięcia

## 📧 Email flow

### Automatyczne maile:
- **Meeting confirmation** → po umówieniu spotkania
- **Offer email** → po wysłaniu oferty (z PDF)
- **Contract notification** → po podpisaniu (planowane)

### Templates lokalizacja:
- `app/views/lead_mailer/`
- HTML + text versions
- Professional styling

## 🔐 Security notes

### Autoryzacja:
- **Admin:** pełny dostęp
- **Sales:** bez usuwania kontraktów/komisji
- **Polityki:** w `app/policies/`

### Dane wrażliwe:
- NIGDY nie commituj credentials
- Użyj ENV variables w production
- Letter opener TYLKO w development

## 💾 Backup ważnych decyzji

### Money handling:
- Wszystkie kwoty w `*_cents` (integer)
- Currency domyślnie 'PLN'
- Money gem dla formatowania

### Status flow:
- `fresh` → `contacted` → `meeting` → `offer` → `won`/`lost`
- Automatyczne zmiany przy akcjach
- `followup` dla potencjalnych klientów

### File uploads:
- ActiveStorage dla zdjęć leadów
- PDF attachments dla ofert/kontraktów
- Local storage w development

---

**Pamiętaj:** Po każdej większej zmianie aktualizuj ROADMAP.md i README.md!