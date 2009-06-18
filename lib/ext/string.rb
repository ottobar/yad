class String
  # Turns a lower_case_underscored_name into an UpperCaseCamelCaseName
  def classify
    self.gsub("_", " ").gsub(/\b('?[a-z])/) { $1.capitalize }.gsub(" ", "")
  end
end
