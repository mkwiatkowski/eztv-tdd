require 'open-uri'
require 'nokogiri'

module Eztv

  @parse_flag = 0

  def self.get_page(number=0)
    Nokogiri::HTML(open("http://eztv.it/page_#{number}"))
  end

  def self.list_the_elements_of_page(page)
    page.search('tr.forum_header_border').map do |tr|
      tr.at('td:nth-child(4)').content.match(/>1 week/) && next
      tr.at('td:nth-child(2)').content.strip
    end.compact
  end

  def self.is_last_page?(page)
    !page.at('tr.forum_header_border:last-child td:nth-child(4)').content.match(/>1 week/).nil?
  end

  def self.search_title
    if ARGV.length > 1
      puts "Usage: eztv.rb [title]"
      raise SystemExit
    else
      (ARGV.length > 0) ? ARGV[0] : ""
    end
  end

  def self.last_week_results
    page = 0
    titles = Array.new
    loop do
      content = get_page(page)
      titles += list_the_elements_of_page(content)
      break if is_last_page?(content)
      page += 1
    end
    titles
  end

  def self.print_last_week_results(search=nil)
    titles = []
    (0..1).each do |page|
      titles += list_the_elements_of_page(get_page(page))
    end
    titles.select!{|title| title.include?(search)} unless search.nil?
    titles.map { |title| puts title }
  end

  def self.finish_process
    @parse_flag < 1
  end

  def self.matching_titles(page)
    list_the_elements_of_page(page).select { |title| title.downcase.include?(search_title.downcase) }
  end
end
