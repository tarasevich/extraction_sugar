module ExtractionSugar
  module NameConversions

    CAMELIZE = ->(name) {
      name.camelize(:lower)
    }

  end
end
