require_relative '../eztv'
require 'open3'

describe Eztv do

  describe '.get_page' do
    it "should use nokogiri" do
      Nokogiri.should_receive(:HTML)
      Eztv.get_page
    end

    it "should connect with eztv by default number" do
      Eztv.should_receive(:open).with("http://eztv.it/page_0")
      Eztv.get_page
    end

    it "should connect with eztv and get the seventh page" do
      Eztv.should_receive(:open).with("http://eztv.it/page_6")
      Eztv.get_page(6)
    end

    it "should throw an error" do
      lambda { Eztv.get_page("strona") }.should raise_error
      lambda { Eztv.get_page(-12) }.should raise_error
    end
  end

  describe '.is_last_page?' do
    context 'when page is last' do
      before do
        @last_page = Nokogiri::HTML("<table><tr class='forum_header_border'><td></td><td></td><td></td><td>&gt;1 week</td></tr></table>")
      end

      it 'should return true when the page contains entry with age > 1' do
        Eztv.is_last_page?(@last_page).should be_true
      end

      it 'should look at "tr.forum_header_border:last-child td:nth-child(4) on last page"' do
        @last_page.should_receive(:at).with('tr.forum_header_border:last-child td:nth-child(4)').and_return(stub(content: ''))
        Eztv.is_last_page?(@last_page)
      end
    end

    context 'when page is not last' do
      before do
        @page = Nokogiri::HTML("<table><tr class='forum_header_border'><td></td><td></td><td></td><td>&gt;6 hours</td></tr></table>");
      end
      it 'should return false when parsed not-last page' do
        Eztv.is_last_page?(@page).should be_false
      end

      it 'should look at "tr.forum_header_border:last-child td:nth-child(4) on not last page"' do
        @page.should_receive(:at).with('tr.forum_header_border:last-child td:nth-child(4)').and_return(stub(content: ''))
        Eztv.is_last_page?(@page)
      end
    end

    it 'should call content method' do
      doc_mock = mock
      doc_mock.should_receive(:content).and_return("")
      Eztv.is_last_page?(stub(at: doc_mock))
    end
  end

  describe '.list_the_elements_of_page' do
    let(:page) {Nokogiri::HTML(File.read('spec/fixtures/index.html'))}
    let(:part_of_page) {part_of_page = Nokogiri::HTML(File.read('spec/fixtures/index_part.html'))}

    it 'should return array' do
      Eztv.list_the_elements_of_page(page).should be_an(Array)
    end

    it 'should return not empty array' do
      Eztv.list_the_elements_of_page(page).should_not be_empty
    end

    it 'should be an array of hashes each with date, title and url keys' do
      episodes = Eztv.list_the_elements_of_page(page)
      episodes[0].should == {
        date: '15, November, 2012',
        title: 'History Ch Crimes That Shook Britain 4of6 Stephanie Slater XviD AC3-MVGroup',
        url: 'http://eztv.it/ep/39673/history-ch-crimes-that-shook-britain-4of6-stephanie-slater-xvid-ac3-mvgroup/'
      }
      episodes[1].should == {
        date: '15, November, 2012',
        title: 'Key and Peele S02E08 HDTV x264-EVOLVE',
        url: 'http://eztv.it/ep/39672/key-and-peele-s02e08-hdtv-x264-evolve/',
      }
      episodes[2].should == {
        date: '15, November, 2012',
        title: 'The Colbert Report 2012 11 14 (HDTV-x264-LMAO) [VTV]',
        url: 'http://eztv.it/ep/39671/the-colbert-report-2012-11-14-hdtv-x264-lmao/'
      }
    end

    it 'should raise NoMethodError' do
      expect {
        Eztv.list_the_elements_of_page("a")
      }.to raise_error(NoMethodError)
    end
  end

  describe 'run' do
    context "for two sample pages" do
      before do
        Eztv.should_receive(:get_page).with(0).at_least(:once).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_part.html")))
        Eztv.should_receive(:get_page).with(1).at_least(:once).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_last.html")))
        $stdout.stub(:puts)
      end

      it "should return titles with first argument provided by user when there is one argument" do
        stub_const("ARGV", ["colbert"])
        $stdout.should_receive(:puts).with("The Colbert Report -> http://eztv.it/ep/39671/the-colbert-report-2012-11-14-hdtv-x264-lmao/ (15, November, 2012)")
        Eztv.run
      end

      it "should return last week results with when there is no arguments" do
        stub_const("ARGV", [])
        $stdout.should_receive(:puts).with("Key and Peele -> http://eztv.it/ep/39672/key-and-peele-s02e08-hdtv-x264-evolve/ (15, November, 2012)")
        Eztv.run
      end

      it "should return titles including all arguments provided by user" do
        stub_const("ARGV", ["colbert", "report"])
        $stdout.should_receive(:puts).with("The Colbert Report -> http://eztv.it/ep/39671/the-colbert-report-2012-11-14-hdtv-x264-lmao/ (15, November, 2012)")
        Eztv.run
      end
    end
  end

  describe '.last_week_results' do
    context "when two pages have elements younger than a week" do
      before do
        Eztv.should_receive(:get_page).with(0).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_part.html")))
        Eztv.should_receive(:get_page).with(1).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_last.html")))
      end

      it "should be called with no arguments" do
        expect {
          Eztv.last_week_results
        }.to_not raise_error
      end

      it "should return an array" do
        Eztv.last_week_results.should be_an(Array)
      end
    end

    context "when a page with a titles older than one week is returned" do
      before do
        Eztv.should_receive(:get_page).with(0).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_last.html")))
      end

      it "should return collection of titles, urls and released dates from last week" do
        episodes = Eztv.last_week_results
        episodes[0].should == {
          date: '15, November, 2012',
          title: 'History Ch Crimes That Shook Britain',
          url: 'http://eztv.it/ep/39673/history-ch-crimes-that-shook-britain-4of6-stephanie-slater-xvid-ac3-mvgroup/'
        }
        episodes[1].should == {
          date: '15, November, 2012',
          title: 'Key and Peele',
          url: 'http://eztv.it/ep/39672/key-and-peele-s02e08-hdtv-x264-evolve/',
        }
      end

      it "should not contain title older than one week" do
        Eztv.last_week_results.map {|ep| ep[:title]}.should_not include('The Colbert Report')
      end
    end
  end

  describe ".print_last_week_results" do
    before do
      Eztv.should_receive(:get_page).with(0).at_least(:once).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_part.html")))
      Eztv.should_receive(:get_page).with(1).at_least(:once).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_last.html")))
      $stdout.stub(:puts)
    end

    it "should receive up to one argument" do
      expect { Eztv.print_last_week_results }.not_to raise_error
      expect { Eztv.print_last_week_results('a') }.not_to raise_error
      expect { Eztv.print_last_week_results('a', 'b') }.to raise_error
    end

    it "should print on screen title, date and url of episodes in right format" do
      $stdout.should_receive(:puts).with("History Ch Crimes That Shook Britain -> http://eztv.it/ep/39673/history-ch-crimes-that-shook-britain-4of6-stephanie-slater-xvid-ac3-mvgroup/ (15, November, 2012)")
      $stdout.should_receive(:puts).with("Key and Peele -> http://eztv.it/ep/39672/key-and-peele-s02e08-hdtv-x264-evolve/ (15, November, 2012)")
      $stdout.should_receive(:puts).with("The Colbert Report -> http://eztv.it/ep/39671/the-colbert-report-2012-11-14-hdtv-x264-lmao/ (15, November, 2012)")
      Eztv.print_last_week_results
    end

    it "should print on screen only those episodes which match argument" do
      $stdout.should_receive(:puts).with("The Colbert Report -> http://eztv.it/ep/39671/the-colbert-report-2012-11-14-hdtv-x264-lmao/ (15, November, 2012)")
      Eztv.print_last_week_results('Colbert')
    end
  end

  describe "application" do
    it "should print on stdout list of last week episodes" do
      stdout, stderr = run_app
      stdout.should_not be_empty
      stderr.should be_empty
      stdout.each_line do |line|
        line.should =~ /^.* -> http:\/\/eztv.it\/ep\/.* (.*)$/
      end
    end

    it "should not contain duplicates" do
      stdout, stderr = run_app("colbert")
      lines = stdout.split("\n")
      lines.should == lines.uniq
    end

    private
    def run_app(arg="")
      Open3.popen3("ruby eztv.rb #{arg}")[1..2].map(&:read)
    end
  end
end
