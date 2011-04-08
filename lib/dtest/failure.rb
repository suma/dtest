
module DTest
  def self.parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file = $1
      line = $2.to_i
      method = $3
      [file, line, method]
    else
      nil
    end
  end

  def self.failure_line(backtrace)
    file, line, method = parse_caller(backtrace)
    if file && line && File.exists?(file)
      [file, line, File.readlines(file)[line - 1].strip]
    else
      [file, line, "Unable to find #{file} to read failed line"]
    end
  end

  def self.failure_caller(level)
    failure_line(caller(level).first)
  end
end # DTest

