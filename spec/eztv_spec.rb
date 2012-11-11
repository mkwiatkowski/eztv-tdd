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

    it "should throw an error"do
      lambda { Eztv.get_page("strona") }.should raise_error
      lambda { Eztv.get_page(-12) }.should raise_error
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