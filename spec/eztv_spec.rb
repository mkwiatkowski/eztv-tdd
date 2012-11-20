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
        @last_page = Nokogiri::HTML("<table><tr class='forum_header_border'><td></td><td></td><td></td><td>&gt;1 week</td></tr></table>");
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
        @last_page.should_receive(:at).with('tr.forum_header_border:last-child td:nth-child(4)').and_return(stub(content: ''))
        Eztv.is_last_page?(@last_page)
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

  describe '.set_title_from_args' do
    it "should return first argument provided by user" do
      stub_const("ARGV", ["some_title", "something_else"])
      Eztv.set_title_from_args.should eq("some_title")
      expect = Eztv.set_title_from_args
      expect.should eq(ARGV.first)
    end

    it "should return empty string if user provided no arguments" do
      stub_const("ARGV", [])
      Eztv.set_title_from_args.should eq("")
    end
  end

  describe '.last_week_results' do
    it "should be called with no arguments" do
      expect {
        Eztv.last_week_results
      }.to_not raise_error
    end

    it "should return an array" do
      Eztv.last_week_results.should be_an(Array)
    end

    it "should return collection with three elements" do
      Eztv.last_week_results.should have(3).items
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

end
