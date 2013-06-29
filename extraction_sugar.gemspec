Gem::Specification.new do |s|
  s.name        = 'extraction_sugar'
  s.version     = '0.0.0'
  s.date        = '2013-06-29'
  s.summary     = "Extraction Sugar"
  s.description = "a mini-framework for defining DSLs to extract data from structures like Nokogiri::XML::Node"
  s.authors     = ["Alexey Tarasevich"]
  s.email       = ''
  s.files       = ["lib/extraction_sugar.rb"]
  s.homepage    = ''
  s.add_dependency "active_support"
  s.add_development_dependency "rspec"
  s.add_development_dependency "nokogiri"
  s.add_development_dependency "i18n"
end
