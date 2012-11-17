class String 
  def symbolize
    self.underscore.gsub(/[\s\-]/, '_').to_sym
  end
end

class Symbol 
  def symbolize
    self.to_s.symbolize
  end
end

class NilClass
  def symbolize
    :nil
  end
end
