# Like interface
module DAL

    module ReadOnlyNetworkRepository

        # uri - url as string
        # conditions - array ( [] )
        # Returns array of arrays ( [ [] ] ) for each condition
        def get(uri, conditions)
            not_implemented()
        end

        # Returns array ( [] ) of all relatie page urls
        def all()
            not_implemented()
        end

        # Checks if any relative page urls is exists
        def any?()
            not_implemented()    
        end
        
        # To not override or access from the outside, excluding inheritance
        private
        protected
        def not_implemented()
            raise("Not implemented")
        end

    end

end