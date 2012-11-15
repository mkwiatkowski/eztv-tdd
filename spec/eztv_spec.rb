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

    it "should connect with eztv and get the sixth page" do
      Eztv.should_receive(:open).with("http://eztv.it/page_6")
      Eztv.get_page(6)
    end

    it "should throw an error" do
      lambda { Eztv.get_page("strona") }.should raise_error
      lambda { Eztv.get_page(-12) }.should raise_error
    end
  end

  describe '.parse_page' do
    it 'should call get_page method' do
      doc_stub = stub(css: [])
      Eztv.should_receive(:get_page).with(0).and_return(doc_stub)
      Eztv.parse_page(0)
    end

    it 'should search for "table.forum_header_border" element on page' do
      doc_stub = stub(last: [])
      doc_mock = mock
      doc_mock.should_receive(:css).with('table.forum_header_border').and_return(doc_stub)
      Nokogiri.stub(:HTML => doc_mock)
      Eztv.parse_page(0)
    end
  end

  describe '.parse_next_page?' do
    before do
      Eztv.stub(open: File.read('spec/fixtures/index.html'))
      Eztv.parse_page(0)
    end

    it 'should be called without arguments' do
      expect { Eztv.parse_next_page?('x') }.to raise_error
    end

    it 'should return true when parsed not-last page' do
      Eztv.parse_next_page?.should be_true
    end

    it 'should return false when parsed last page' do
      Eztv.stub(open: File.read('spec/fixtures/index_last.html'))
      Eztv.parse_page(0)
      Eztv.parse_next_page?.should be_false
    end

    it 'should call content method' do
      page = Eztv.instance_variable_get(:@page)
      doc_mock = mock
      doc_mock.should_receive(:content).and_return("")
      page.stub( :at => doc_mock )
      Eztv.parse_next_page?
    end

    it 'should look at "tr.forum_header_border:last-child td:nth-child(4)"' do
      page = Eztv.instance_variable_get(:@page)
      page.should_receive(:at).with('tr.forum_header_border:last-child td:nth-child(4)').and_return(stub(content: ''))
      Eztv.parse_next_page?
    end
  end

  describe '.list_the_elements_of_page' do
    it 'should return array' do
      Eztv.list_the_elements_of_page(0).should be_an(Array)
    end

    it 'should return not empty array' do
      Eztv.list_the_elements_of_page(0).should_not be_empty
    end

    it 'should throw an error' do
      lambda { Eztv.list_the_elements_of_page("a") }.should raise_error
    end

    it 'should contain titles' do
      doc_mock = mock
      doc_mock.should_receive(:xpath).with("//td[@class='forum_thread_post']/a[@class='epinfo']/text()").and_return([])
      Eztv.stub(:parse_page => doc_mock)
      Eztv.list_the_elements_of_page(0)
    end

    it 'should call parse_page method' do
      doc_stub = stub(xpath: [])
      Eztv.should_receive(:parse_page).with(0).and_return(doc_stub)
      Eztv.list_the_elements_of_page(0)
    end
  end

  describe '.set_title_from_args' do
    it "should return first argument provided by user" do
      stub_const("ARGV", ["some_title", "something_else"])
      Eztv.set_title_from_args.should eq("some_title")
      expect = Eztv.set_title_from_args
      expect.should eq(ARGV.first)
    end

    it "should return nil if user provided no arguments" do
      stub_const("ARGV", [])
      Eztv.set_title_from_args.should be_nil
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

end
