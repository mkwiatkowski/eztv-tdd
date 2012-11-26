require_relative '../eztv'

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

    it "should return ['History Ch Crimes That Shook Britain', 'Key and Peele', 'The Colbert Report']" do
      Eztv.list_the_elements_of_page(part_of_page).should == ['History Ch Crimes That Shook Britain', 'Key and Peele', 'The Colbert Report']
    end

    it 'should raise NoMethodError' do
      expect {
        Eztv.list_the_elements_of_page("a")
      }.to raise_error(NoMethodError)
    end
  end

  describe '.search_title' do
    it "should return first argument provided by user" do
      stub_const("ARGV", ["some_title"])
      Eztv.search_title.should eq("some_title")
      expect = Eztv.search_title
      expect.should eq(ARGV.first)
    end

    it "should return empty string if user provided no arguments" do
      stub_const("ARGV", [])
      Eztv.search_title.should eq("")
    end

    it "should return message and leave when there is more than one argument" do
      stub_const("ARGV", ["title", "extra_argument"])
      $stdout.should_receive(:puts).with("Usage: eztv.rb [title]")
      Eztv.should_receive(:raise).with(SystemExit)
      Eztv.search_title
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

      it "should return collection of titles from last week" do
        Eztv.last_week_results.should eq(['History Ch Crimes That Shook Britain', 'Key and Peele'])
      end

      it "should not contain title older than one week" do
        Eztv.last_week_results.should_not include('The Colbert Report')
      end
    end
  end

  describe ".print_last_week_results" do
    before do
      Eztv.should_receive(:get_page).with(0).at_least(:once).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_part.html")))
      Eztv.should_receive(:get_page).with(1).at_least(:once).and_return(Nokogiri::HTML(File.read("spec/fixtures/index_last.html")))
    end

    it "should receive up to one argument" do
      expect { Eztv.print_last_week_results }.not_to raise_error
      expect { Eztv.print_last_week_results('a') }.not_to raise_error
      expect { Eztv.print_last_week_results('a', 'b') }.to raise_error
    end

    it "should print on screen titles separated by new line" do
      $stdout.should_receive(:puts).with("History Ch Crimes That Shook Britain").twice
      $stdout.should_receive(:puts).with("Key and Peele").twice
      $stdout.should_receive(:puts).with("The Colbert Report")
      Eztv.print_last_week_results
    end

    it "should print on screen only those titles which match to argument" do
      $stdout.should_receive(:puts).with('The Colbert Report')
      Eztv.print_last_week_results('Colbert')
    end
  end

  describe '.finish_process' do
    context "true" do
      it "should return true" do
        Eztv.finish_process.should == true
      end
    end
  end

  describe ".matching_titles" do
    let(:page) {Nokogiri::HTML(File.read('spec/fixtures/index_part.html'))}

    it "should return array" do
      Eztv.matching_titles(page).should be_an(Array)
    end

    it "should return all titles when no user arguments are passed" do
      stub_const("ARGV", [])
      Eztv.matching_titles(page).should eq(["History Ch Crimes That Shook Britain", "Key and Peele", "The Colbert Report"])
    end

    it "should return only matching titles" do
      stub_const("ARGV", ["crimes"])
      Eztv.matching_titles(page).should eq(["History Ch Crimes That Shook Britain"])
    end
  end

  describe '.list_the_elements_of_page' do
    let(:page) {Nokogiri::HTML(File.read('spec/fixtures/index.html'))}

    it 'should contain date url and title' do
      episodes = Eztv.list_the_elements_of_page(page)
      episodes[0][:date].should eql('15, November, 2012')
      episodes[0][:title].should eql('History Ch Crimes That Shook Britain 4of6 Stephanie Slater XviD AC3-MVGroup')
      episodes[0][:url].should eql('http://eztv.it/ep/39673/history-ch-crimes-that-shook-britain-4of6-stephanie-slater-xvid-ac3-mvgroup/')
    end

    it 'each element should be and instance of Hash' do
      Eztv.list_the_elements_of_page(page)[0].should be_an(Hash)
    end
  end
end