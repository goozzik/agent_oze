class MeasurementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_lead
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]

  def new
    @measurement = @lead.measurements.build
    authorize @measurement
  end

  def create
    @measurement = @lead.measurements.build(measurement_params)
    @measurement.measured_by = current_user
    authorize @measurement

    if @measurement.save
      redirect_to [@lead, @measurement], notice: 'Pomiar został utworzony.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @measurement
  end

  def edit
    authorize @measurement
  end

  def update
    authorize @measurement

    if @measurement.update(measurement_params)
      redirect_to [@lead, @measurement], notice: 'Pomiar został zaktualizowany.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @measurement
    @measurement.destroy
    redirect_to @lead, notice: 'Pomiar został usunięty.'
  end

  private

  def set_lead
    @lead = Lead.find(params[:lead_id])
  end

  def set_measurement
    @measurement = @lead.measurements.find(params[:id])
  end

  def measurement_params
    params.require(:measurement).permit(
      :measurement_type, :room_name, :length, :width, :height, :notes
    )
  end
end