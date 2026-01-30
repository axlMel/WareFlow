class ExcelImporter
  def self.open(file)
    Roo::Spreadsheet.open(file.path, extension: :xlsx)
  end
end