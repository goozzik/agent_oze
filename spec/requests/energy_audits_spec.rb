require 'rails_helper'

RSpec.describe "EnergyAudits", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/energy_audits/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/energy_audits/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/energy_audits/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/energy_audits/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/energy_audits/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/energy_audits/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
