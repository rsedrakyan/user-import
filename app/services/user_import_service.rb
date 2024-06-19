require 'csv'

class UserImportService
  attr_reader :file, :results

  def initialize(file)
    @file = file
    @results = []
  end

  def call!
    # validate the file and import
  end
end
