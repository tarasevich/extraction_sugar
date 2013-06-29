module ExtractionSugar
  module Macros
    STRING_OR_SYMBOL = lambda do |s|
      String === s || Symbol === s or raise ArgumentError, s.class.name
    end

    def define_extractor(extractor_name, &function)
      STRING_OR_SYMBOL.(extractor_name)
      name_str = extractor_name.is_a?(Symbol) ? extractor_name.to_s : extractor_name

      send :define_method, extractor_name do |&dsl_block|
        MethodCapture.new do |attr_name, *args, &block|
          STRING_OR_SYMBOL.(attr_name)
          attr_str = attr_name.to_s.freeze

          define_method attr_name do
            # TODO: cache
            instance_exec(attr_str, &function)
          end
        end.instance_eval(&dsl_block)
      end

    end

  end
end
