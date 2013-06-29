require 'active_support'

module ExtractionSugar
  module Macros
    extend ActiveSupport::Concern

    STRING_OR_SYMBOL = lambda do |s|
      String === s || Symbol === s or raise ArgumentError, s.class.name
    end

    included do
      extend ActiveSupport::Concern
      extend ActiveSupport::Memoizable

      const_set :ClassMethods, Module.new {
        include Macros::ClassMethods

        def apply_conversion(conversion)
          @default_conversion = conversion
        end

        private

        def convert_name(attr_name, pattern = nil)
          unless pattern
            pattern = attr_name.to_s.freeze
            pattern = @default_conversion.(pattern) if @default_conversion
          end

          pattern
        end
      }
    end

    module ClassMethods
      def define_extractor(extractor_name, &function)
        arity = function.arity - 1
        STRING_OR_SYMBOL.(extractor_name)
        name_str = extractor_name.is_a?(Symbol) ? extractor_name.to_s : extractor_name

        # define a macro that would define attributes
        const_get(:ClassMethods).
        send :define_method, extractor_name do |&definitions_block|
          MethodCapture.new do |attr_name, *args, &ingore_block|
            STRING_OR_SYMBOL.(attr_name)
            function_args = args.pop(arity)
            pattern = convert_name(attr_name, *args)

            # define attribute reader
            eval <<-END, binding, __FILE__, __LINE__
              define_method attr_name do
                @#{attr_name} ||= instance_exec(pattern, *function_args, &function)
              end
            END
          end.instance_eval(&definitions_block)
        end

        # define a convinience method for other macros
        define_method extractor_name do |*args|
          instance_exec(*args, &function)
        end
      end

      def extract(&definitions_block)
        MethodCapture.new do |attr_name, &block|
          eval <<-END, binding, __FILE__, __LINE__
            define_method attr_name do
              @#{attr_name} ||= instance_eval(&block)
            end
          END
        end.instance_eval(&definitions_block)
      end
    end

  end
end
