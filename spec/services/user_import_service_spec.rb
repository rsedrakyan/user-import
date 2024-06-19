# spec/services/user_import_service_spec.rb
require 'rails_helper'

RSpec.describe UserImportService do
  let(:valid_csv_path) { Rails.root.join('spec/fixtures/files/users.csv') }
  let(:invalid_csv_path) { Rails.root.join('spec/fixtures/files/invalid_file.txt') }
  let(:malformed_csv_path) { Rails.root.join('spec/fixtures/files/malformed_users.csv') }
  let(:missing_columns_csv_path) do
    Rails.root.join('spec/fixtures/files/missing_columns_users.csv')
  end

  let(:valid_file) { fixture_file_upload(valid_csv_path, 'text/csv') }
  let(:invalid_file) { fixture_file_upload(invalid_csv_path, 'text/plain') }
  let(:malformed_file) { fixture_file_upload(malformed_csv_path, 'text/csv') }
  let(:missing_columns_file) { fixture_file_upload(missing_columns_csv_path, 'text/csv') }

  describe '#call!' do
    context 'with a valid CSV file' do
      it 'processes the file and creates users' do
        service = UserImportService.new(valid_file)
        results = service.call!

        expect(results).to include({ status: 'success' })
        expect(User.count).to eq(1)
      end
    end

    context 'when no file is provided' do
      it 'raises an ArgumentError for missing file' do
        service = UserImportService.new(nil)

        expect {
          service.call!
        }.to raise_error(ArgumentError, I18n.t('users.upload.errors.missing_file'))
      end
    end

    context 'with an invalid file type' do
      it 'raises an ArgumentError for invalid file type' do
        service = UserImportService.new(invalid_file)

        expect { service.call! }
          .to raise_error(ArgumentError, I18n.t('users.upload.errors.invalid_csv_file'))
      end
    end

    context 'with a malformed CSV file' do
      it 'raises an ArgumentError for malformed CSV content' do
        service = UserImportService.new(malformed_file)

        expect { service.call! }
          .to raise_error(ArgumentError, I18n.t('users.upload.errors.invalid_csv_file'))
      end
    end

    context 'with a CSV file missing required columns' do
      it 'raises an ArgumentError for missing columns' do
        service = UserImportService.new(missing_columns_file)

        expect { service.call! }
          .to raise_error(ArgumentError, I18n.t('users.upload.errors.invalid_csv_content'))
      end
    end

    context 'when rows have blank name and password' do
      it 'skips those rows' do
        csv_text = "name,password\n,"
        file = double('file', path: 'fake_path', content_type: 'text/csv')
        allow(File).to receive(:read).with('fake_path').and_return(csv_text)

        service = UserImportService.new(file)
        results = service.call!

        expect(results).to include({ status: 'skip' })
      end
    end

    context 'when rows have invalid user data' do
      it 'returns errors for invalid users' do
        csv_text = "name,password\nInvalid User,"
        file = double('file', path: 'fake_path', content_type: 'text/csv')
        allow(File).to receive(:read).with('fake_path').and_return(csv_text)

        service = UserImportService.new(file)
        results = service.call!

        expect(results).to include(
          a_hash_including(
            status: 'error',
            errors: array_including("Password can't be blank")
          )
        )
      end
    end
  end
end
