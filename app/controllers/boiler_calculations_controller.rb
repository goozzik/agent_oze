class BoilerCalculationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_lead
  before_action :set_boiler_calculation, only: [:show, :edit, :update, :destroy]

  def new
    @boiler_calculation = @lead.boiler_calculations.build
    authorize @boiler_calculation
  end

  def create
    @boiler_calculation = @lead.boiler_calculations.build(boiler_calculation_params)
    @boiler_calculation.created_by = current_user
    authorize @boiler_calculation

    if @boiler_calculation.save
      redirect_to [@lead, @boiler_calculation], notice: 'Kalkulacja pieca została utworzona.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @boiler_calculation
  end

  def edit
    authorize @boiler_calculation
  end

  def update
    authorize @boiler_calculation

    if @boiler_calculation.update(boiler_calculation_params)
      redirect_to [@lead, @boiler_calculation], notice: 'Kalkulacja pieca została zaktualizowana.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @boiler_calculation
    @boiler_calculation.destroy
    redirect_to @lead, notice: 'Kalkulacja pieca została usunięta.'
  end

  private

  def set_lead
    @lead = Lead.find(params[:lead_id])
  end

  def set_boiler_calculation
    @boiler_calculation = @lead.boiler_calculations.find(params[:id])
  end

  def boiler_calculation_params
    params.require(:boiler_calculation).permit(
      :heating_area, :current_heating_type, :desired_power, 
      :recommended_boiler, :calculation_notes, :estimated_cost
    )
  end
end