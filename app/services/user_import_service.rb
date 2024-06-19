require 'csv'

class UserImportService
  attr_reader :file, :results

  def initialize(file)
    @file = file
    @results = []
  end

  def call!
    validate_csv_file!
    csv_text = read_file(file)
    csv = parse_csv(csv_text)
    validate_csv_headers!(csv)
    csv.each { |row| results << save_user(row) }
    results
  end

  private

  def save_user(row)
    name = row['name']&.strip
    password = row['password']&.strip
    return { status: 'skip' } if name.blank? && password.blank?

    user = User.new(name:, password:)
    return { status: 'success' } if user.save

    { status: 'error', errors: user.errors.full_messages }
  end

  def validate_csv_file!
    raise ArgumentError, I18n.t('users.upload.errors.missing_file') if file.blank?

    return if file.content_type == 'text/csv'

    raise ArgumentError, I18n.t('users.upload.errors.invalid_csv_file')
  end

  def read_file(file)
    content = File.read(file.path)
    content.gsub(/\r\n?/, "\n") # Normalize newlines
  rescue Errno::ENOENT
    raise ArgumentError, I18n.t('users.upload.errors.file_read_error')
  end

  def parse_csv(csv_text)
    CSV.parse(csv_text, headers: true)
  rescue CSV::MalformedCSVError
    raise ArgumentError, I18n.t('users.upload.errors.invalid_csv_file')
  end

  def validate_csv_headers!(csv)
    return if csv.headers.include?('name') && csv.headers.include?('password')

    raise ArgumentError, I18n.t('users.upload.errors.invalid_csv_content')
  end
end
