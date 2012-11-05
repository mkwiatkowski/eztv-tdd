require_relative '../eztv'

describe Eztv do
  describe '.last_week_results' do
    it "should be called with no arguments" do
      expect {
        Eztv.last_week_results
      }.to_not raise_error
    end

    it "should return an array" do
      Eztv.last_week_results.should be_an(Array)
    end
  end
end
