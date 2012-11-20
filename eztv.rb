require 'open-uri'
require 'nokogiri'

module Eztv

  @parse_flag = 0

  def self.get_page(number=0)
    Nokogiri::HTML(open("http://eztv.it/page_#{number}"))
  end

  def self.list_the_elements_of_page(page)
    page.css("table.forum_header_border").last.xpath("//td[@class='forum_thread_post']/a[@class='epinfo']/text()").to_a.map(&:text)
  end

  def self.is_last_page?(page)
    !page.at('tr.forum_header_border:last-child td:nth-child(4)').content.match(/>1 week/).nil?
  end

  def self.set_title_from_args
    (ARGV.length > 0) ? ARGV[0] : ""
  end

  def self.last_week_results
    [1, 2, 3]
  end

  def self.finish_process
    @parse_flag < 1
  end

  def self.matching_titles(page)
    list_the_elements_of_page(page).delete_if {|title| !title.downcase.include? set_title_from_args.downcase}
  end
end
