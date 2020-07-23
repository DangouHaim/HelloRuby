module DAL
    class Context
        
        attr_reader :context
        attr_reader :condition

        private
        attr_writer :context
        attr_writer :condition

        def initialize(context, condition)
            @context = context
            @condition = condition
        end

    end
end