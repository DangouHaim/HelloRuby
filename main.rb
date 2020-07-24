load 'dal/network_repository.rb'
load 'dal/csv_storage.rb'

require 'rubygems'
require 'thread/pool'
require 'concurrent'

class Main
    include DAL

    @repository

    def initialize
        puts ">> #{self.class} : #{__method__}"

        source = 'http://arcosplus.by/'

        @repository = NetworkRepository.new(source, true)

        # Using thread pool to optimize accessing to threads
        @pool = Thread.pool(8)

        call = Proc.new { init() }

        p "Total elapsed time : " + elapsed(call)[0].to_s()

        # Call this twice to show optimized call
        p "Total elapsed time : " + elapsed(call)[0].to_s()

        @pool.shutdown()

        puts "<< #{self.class} : #{__method__}"
    end

    private def init()

        puts ">> #{self.class} : #{__method__}"

        categoryPage = "/katalog-kofe/?dataType=Vergnano"
        pageButton = '//div[@class="post"]//a[@class="button"]/@href'
        core_count = 8

        context = Context.new(categoryPage, pageButton)
            
        
        @repository.context = context

        # Thread safe array
        elapsed_times = Concurrent::Array.new
        results = Concurrent::Array.new
        
        if(@repository.any?())
            @repository.all().each() do |page|

                call = Proc.new do
                    @repository.get(page, [ "//div[@class='content']/h3", "//div[@class='content']/p" ])
                end

                res = elapsed(call)

                puts 'Get elapsed time : ' + res[0].to_s()
                elapsed_times << res[0].to_s()
                
                result = []
                
                result << res[1][0][0].children.text.strip()
                result << res[1][1][0].children.text.strip()
                result << res[0].to_s()

                results << result

            end
        end
        
        p results
        
        CsvStorage.new.save(results, "results.csv")

        puts "<< #{self.class} : #{__method__}"
    end

    def elapsed(method)
        time = Time.now()

        result = method.call()

        return [ Time.now() - time, result ]
    end
end

Main.new