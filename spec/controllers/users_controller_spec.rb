require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #upload' do
    it 'calls the import service' do
      file = 'some file'
      user_import_instance = instance_double 'UserImportService', call!: []
      allow(UserImportService).to receive(:new).with(file).and_return(user_import_instance)

      post :upload, params: { file: }

      expect(UserImportService).to have_received(:new).with(file)
    end

    context 'when the service returns results' do
      before do
        allow_any_instance_of(UserImportService).to receive(:call!).and_return([])
      end

      it 'renders the index template with success status' do
        post :upload, params: { file: 'some file' }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the UserImport service raises an ArgumentError' do
      let(:error_message) { 'Some validation issue' }
      before do
        allow(UserImportService).to receive(:new).and_raise(ArgumentError, error_message)
      end

      it 'sets a flash error message ' do
        post :upload
        expect(flash[:error]).to eq(error_message)
      end

      it 'renders the index template with unprocessable_entity status' do
        post :upload
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
