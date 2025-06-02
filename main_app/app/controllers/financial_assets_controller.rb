class FinancialAssetsController < ApplicationController
  before_action :set_asset, only: %i[update destroy]

  def index
    @assets = current_user.assets
  end

  def create
    @asset = current_user.assets.new(asset_params)
    if @asset.save
      redirect_to financial_assets_path, notice: 'Asset created successfully'
    else
      render :new, alert: 'Error creating asset'
    end
  end

  def update
    @asset.update!(asset_params)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "asset_row_#{@asset.id}",
          partial: 'financial_assets/row',
          locals: { asset: @asset }
        )
      end
    end
  end

  def destroy
    @asset.destroy
    redirect_to financial_assets_path, notice: 'Asset deleted successfully'
  end

  private

  def asset_params
    params.require(:asset).permit(:name, :description, :asset_type, :value)
  end

  def set_asset
    @asset = current_user.assets.find(params[:id])
  end
end
