class ForecastTypesController < ApplicationController
  # GET /forecast_types
  # GET /forecast_types.json
  def index
    @forecast_types = ForecastType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @forecast_types }
    end
  end

  # GET /forecast_types/1
  # GET /forecast_types/1.json
  def show
    @forecast_type = ForecastType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @forecast_type }
    end
  end

  # GET /forecast_types/new
  # GET /forecast_types/new.json
  def new
    @forecast_type = ForecastType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @forecast_type }
    end
  end

  # GET /forecast_types/1/edit
  def edit
    @forecast_type = ForecastType.find(params[:id])
  end

  # POST /forecast_types
  # POST /forecast_types.json
  def create
    @forecast_type = ForecastType.new(params[:forecast_type])

    respond_to do |format|
      if @forecast_type.save
        format.html { redirect_to @forecast_type, notice: 'Forecast type was successfully created.' }
        format.json { render json: @forecast_type, status: :created, location: @forecast_type }
      else
        format.html { render action: "new" }
        format.json { render json: @forecast_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /forecast_types/1
  # PUT /forecast_types/1.json
  def update
    @forecast_type = ForecastType.find(params[:id])

    respond_to do |format|
      if @forecast_type.update_attributes(params[:forecast_type])
        format.html { redirect_to @forecast_type, notice: 'Forecast type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @forecast_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forecast_types/1
  # DELETE /forecast_types/1.json
  def destroy
    @forecast_type = ForecastType.find(params[:id])
    @forecast_type.destroy

    respond_to do |format|
      format.html { redirect_to forecast_types_url }
      format.json { head :no_content }
    end
  end
end
