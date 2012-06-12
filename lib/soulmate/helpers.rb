module Soulmate
  module Helpers

    def prefixes_for_phrase(phrase)
      words = normalize(phrase).split(' ')
      results = words.map do |w|
        (MIN_COMPLETE-1..(w.length-1)).map{ |l| w[0..l] }
      end.uniq
      results_scores(results)
    end

    def normalize(str)
      str.downcase.gsub(/[^a-z0-9 ]/i, '').strip
    end
    
    private
    
    def results_scores(results)
      end_results = []
      (0..(results.count-1)).each do |i|
        (0..(results[i].count-1)).each do |p|
          unless p == results[i].count-1
            end_results << [results[i][p],p+1]
          else
            end_results << [results[i][p],100]
          end
          
        end
      end
      end_results    
    end
    
  end
end