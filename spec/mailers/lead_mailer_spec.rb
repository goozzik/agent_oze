require "rails_helper"

RSpec.describe LeadMailer, type: :mailer do
  describe "meeting_confirmation" do
    let(:mail) { LeadMailer.meeting_confirmation }

    it "renders the headers" do
      expect(mail.subject).to eq("Meeting confirmation")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "offer_email" do
    let(:mail) { LeadMailer.offer_email }

    it "renders the headers" do
      expect(mail.subject).to eq("Offer email")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
