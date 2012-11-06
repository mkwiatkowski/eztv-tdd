module Eztv
  @parse_flag = 0

  def self.last_week_results
    []
  end

  def self.finish_process
    @parse_flag < 1
  end
end
