require 'rails_helper'

RSpec.describe "BoilerCalculations", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/boiler_calculations/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/boiler_calculations/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/boiler_calculations/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/boiler_calculations/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/boiler_calculations/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/boiler_calculations/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
