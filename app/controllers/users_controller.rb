class UsersController < ApplicationController
  def index; end

  def upload
    results = UserImportService.new(params[:file]).call!
    render turbo_stream: turbo_stream.update('results', partial: 'results', locals: { results: })
  rescue ArgumentError => e
    flash[:error] = e.message
    render :index, status: :unprocessable_entity
  end
end
