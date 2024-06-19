class UsersController < ApplicationController
  def index; end

  def upload
    @results = UserImportService.new(params[:file]).call!
    render :index, status: :ok
  rescue ArgumentError => e
    flash[:error] = e.message
    render :index, status: :unprocessable_entity
  end
end
