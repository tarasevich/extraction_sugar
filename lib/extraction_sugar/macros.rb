require 'active_support'

module ExtractionSugar
  module Macros
    extend ActiveSupport::Concern

    STRING_OR_SYMBOL = lambda do |s|
      String === s || Symbol === s or raise ArgumentError, s.class.name
    end

    included do
      extend ActiveSupport::Concern
      const_set :ClassMethods, Module.new {

        def apply_conversion(conversion)
          @default_conversion = conversion
        end

        private

        def convert_name(attr_name)
          pattern = attr_name.to_s.freeze
          pattern = @default_conversion.(pattern) if @default_conversion
          pattern
        end
      }
    end

    module ClassMethods
      def define_extractor(extractor_name, &function)
        STRING_OR_SYMBOL.(extractor_name)
        name_str = extractor_name.is_a?(Symbol) ? extractor_name.to_s : extractor_name

        # define a macro that would define attributes
        const_get(:ClassMethods).
        send :define_method, extractor_name do |&dsl_block|
          MethodCapture.new do |attr_name, *args, &block|
            STRING_OR_SYMBOL.(attr_name)
            pattern = convert_name(attr_name)

            # define attribute reader
            define_method attr_name do
              # TODO: cache
              instance_exec(pattern, &function)
            end
          end.instance_eval(&dsl_block)
        end

        # define a convinience method for other macros
        define_method extractor_name do |pattern|
          instance_exec(pattern, &function)
        end
      end

    end

  end
end
