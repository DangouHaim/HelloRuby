load 'dal/network_repository.rb'

require 'rubygems'
require 'thread/pool'
require 'concurrent'

class Main
    include DAL

    @repository

    def initialize
        source = 'http://arcosplus.by/'

        @repository = NetworkRepository.new(source, true)

        # Using thread pool to optimize accessing to threads
        @pool = Thread.pool(8)

        call = Proc.new { init() }

        p "Total elapsed time : " + elapsed(call)[0].to_s()

        # Call this twice to show optimized call
        p "Total elapsed time : " + elapsed(call)[0].to_s()

        @pool.shutdown()
    end

    private def init()

        categoryPage = "/katalog-kofe/?dataType=Vergnano"
        pageButton = '//div[@class="post"]//a[@class="button"]/@href'
        core_count = 8

        context = Context.new(categoryPage, pageButton)
            
        
        @repository.context = context

        # Thread safe array
        results = Concurrent::Array.new
        
        if(@repository.any?())
            @repository.all().each() do |page|

                call = Proc.new do
                    @repository.get(page, [ "//div[@class='content']/h3" ])
                end

                res = elapsed(call)
                results << [ res[0].to_s(), res[1][0][0].children.text.strip()]

            end
        end
        
        p results

    end

    def elapsed(method)
        time = Time.now()

        result = method.call()

        return [ Time.now() - time, result ]
    end
end

Main.new