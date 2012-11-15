require 'open-uri'
require 'nokogiri'

module Eztv

  @parse_flag = 0

  def self.get_page(number=0)
    Nokogiri::HTML(open("http://eztv.it/page_#{number}"))
  end

  def self.parse_page(number)
    doc = get_page(number)
    @page = doc.css("table.forum_header_border").last
  end

  def self.list_the_elements_of_page(number)
    parse_page(number).xpath("//td[@class='forum_thread_post']/a[@class='epinfo']/text()").to_a
  end

  def self.parse_next_page?
     @page.at('tr.forum_header_border:last-child td:nth-child(4)').content.match(/>1 week/).nil?
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
