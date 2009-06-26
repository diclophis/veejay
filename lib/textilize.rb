
class String
  def textilize
    RedCloth.new(self, [:no_span_caps]).to_html
  end
end
