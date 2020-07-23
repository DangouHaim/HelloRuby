load 'readonlynetworkrepository.rb'
load 'context.rb'

require 'net/http'
require 'digest/sha1'
require 'nokogiri'

module DAL

    class NetworkRepository

        # To implement interface
        include ReadOnlyNetworkRepository
        
        # Context for collecting urls (for all() and any?() methods)
        attr_reader :context
        attr_reader :cached
        attr_reader :source
        attr_reader :pages

        private
        attr_writer :cached
        attr_writer :source
        attr_writer :pages

        def initialize(source_uri, cached = false)
            @context = context
            @cached = cached
            @source = source_uri.to_s()

            # Method caching
            @cache = Concurrent::Hash.new
        end

        # Interface part
        public

        def get(uri, conditions)
            if @cached
                # Caching html parsing to not repeat same operations
                hash = Digest::SHA1.hexdigest(uri + conditions.sort().to_s())
                return @cache[hash] ||= get_page(uri, conditions)
            else
                return get_page(uri, conditions)
            end
        end

        def any?()
            return !@pages.empty?()
        end

        def all()
            return @pages
        end
        # Interface part end

        def context=(context)
            @context = context
            
            if(@cached)
                # Caching html parsing to not repeat same operations
                # with same html
                hash = Digest::SHA1.hexdigest(@source + @context.to_s())
                @pages = @cache[hash] ||= prepare_pages_from_source(@source, @context)
            else
                @pages = prepare_pages_from_source(@source, @context)
            end
        end

        private

        # Parsing pages relative urls from base url
        def prepare_pages_from_source(source, context)
            raise( "Invalid context" ) if !context.is_a?(Context)

            uri = uri.to_s

            uri = URI::join(source.to_s(), context.context.to_s).to_s if !uri.include?(source)
            uri = URI.parse(uri)
            
            html = Net::HTTP.get(uri)

            document = Nokogiri::HTML(html)

            results = []

            for item in document.xpath(context.condition)
                results << item.value
            end
            
            return results
        end

        # Get parsed page data by url or relative url
        def get_page(uri, conditions)
            uri = uri.to_s()
            
            uri = URI::join(@source, uri).to_s if !uri.include?(@source)
            uri = URI.parse(uri)

            html = Net::HTTP.get(uri)

            if @cached
                # Caching html parsing to not repeat same operations
                # with same html
                hash = Digest::SHA1.hexdigest(html + conditions.sort().to_s())
                return @cache[hash] ||= parse_html(html, conditions)
            else
                return parse_html(html, conditions)
            end
        end

        # Apply xPath to html to get required data
        def parse_html(html, conditions)
            document = Nokogiri::HTML(html)
            result = []
            
            for c in conditions
                temp = []
                for item in document.xpath(c)
                    temp << item
                end
                result << temp
            end
            
            return result
        end
        
    end

end