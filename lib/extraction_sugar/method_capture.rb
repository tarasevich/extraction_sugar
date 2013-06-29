module ExtractionSugar
  class MethodCapture < BasicObject
    def initialize(&block)
      @block = block
    end

    def method_missing(*args, &block)
      @block.(*args, &block)
    end
  end
end
