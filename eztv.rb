require 'open-uri'
require 'nokogiri'

module Eztv
  def self.get_page(number=0)
    Nokogiri::HTML(open("http://eztv.it/page_#{number}"))
  end

  def self.list_the_elements_of_page(page)
    releases, added = [], ''
    page.search('tr').each do |tr|
      added = tr.content.strip.match(/Added on: (.+)/)[1] if tr['class'].eql?('forum_space_border')

      if tr['class'].eql?('forum_header_border')
        next if tr.at('td:nth-child(4)').content.match(/>1 week/)
        title = tr.at('td:nth-child(2)')

        releases.push(
          date: added,
          title: title.content.strip,
          url: 'http://eztv.it' + title.at('a')['href']
        )
      end
    end

    releases
  end

  def self.is_last_page?(page)
    !page.at('tr.forum_header_border:last-child td:nth-child(4)').content.match(/>1 week/).nil?
  end

  def self.run
    print_last_week_results(ARGV[0])
  end

  def self.last_week_results
    page = 0
    episodes = []
    loop do
      content = get_page(page)
      episodes += list_the_elements_of_page(content)
      break if is_last_page?(content)
      page += 1
    end
    episodes.uniq
  end

  def self.print_help_and_exit
    puts "Usage: eztv.rb [title]"
    exit
  end

  def self.print_last_week_results(search_term=nil)
    print_results(select_matching(last_week_results, search_term))
  end

  def self.print_results(episodes)
    episodes.each do |ep|
      puts(ep[:title] + ' -> ' + ep[:url] + ' (' + ep[:date] + ')')
    end
  end

  def self.select_matching(episodes, search_term)
    if search_term
      episodes.select {|ep| ep[:title].downcase.include?(search_term.downcase)}
    else
      episodes
    end
  end
end

if __FILE__ == $0
  Eztv.run
end
