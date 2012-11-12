require 'open-uri'
require 'nokogiri'

module Eztv

  @parse_flag = 0

  def self.get_page(number=0)
    Nokogiri::HTML(open("http://eztv.it/page_#{number}"))
  end

  def self.set_title_from_args
    (ARGV.length > 0) ? ARGV[0] : nil
  end
    
  def self.last_week_results
    [1, 2, 3]
  end

  def self.finish_process
    @parse_flag < 1
  end
end