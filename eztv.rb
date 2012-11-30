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
    if ARGV.length > 1
      puts "Usage: eztv.rb [title]"
      raise SystemExit
    else
      episodes = last_week_results
      if ARGV.length == 1
        episodes.select! {|e| e[:title].downcase.include?(ARGV[0].downcase)}
      end
      episodes.map {|e| puts e[:title] + ' -> ' + e[:url] + ' (' + e[:date] + ')'}
    end
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
    episodes
  end

  def self.print_last_week_results(search=nil)
    episodes = last_week_results
    episodes.select!{|ep| ep[:title].include?(search)} unless search.nil?
    episodes.map { |ep| puts ep[:title] + ' -> ' + ep[:url] + ' (' + ep[:date] + ')'}
  end
end
