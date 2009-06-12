class String
  def classify
    self.gsub("_", " ").gsub(/\b('?[a-z])/) { $1.capitalize }.gsub(" ", "")
  end
end
