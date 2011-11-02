
module DTest
  class Report
    private
    TAG_BASE = [
      'Global', 'TestCase', 'Test', 'RUN', 'OK', 'FAIL',
      'PASSED', 'FAILED', 'TESTED', 'UNTEST',
    ]
    TAG_S = TAG_BASE.map {|t| " #{t} "}
    MAX_LEN = TAG_S.map {|s| s.size}.max

    TAG_MAP = Hash[[TAG_BASE.map {|t| t.downcase.to_sym}, TAG_S].transpose].merge({
      :line => '-' * MAX_LEN,
      :empty => ''
    })

    TAGS_COLOR = {
      :global => :blue,
      :testcase => :blue,
      :test => :blue,

      :run => :yellow,
      :fail => :red,
      :ok => :green,

      :passed => :green,
      :failed => :green,
      :tested => :green,
      :untest => :green,
    }

    # symbol to string
    def self.tag_s(tag)
      # must be in TAG_MAP.include?(tag)
      TAG_MAP[tag]
    end

    def self.colored_tag(tag)
      text = tag_s(tag)

      if TAGS_COLOR.include?(tag)
        send(TAGS_COLOR[tag], text)
      else
        text
      end
    end

    def self.space(size)
      if size > 0
        ' ' * size
      else
        ''
      end
    end

    def self.s_center(tag)
      len = MAX_LEN - tag_s(tag).size
      left = len / 2
      right = len / 2 + (len.odd? ? 1 : 0)
      space(left) + colored_tag(tag) + space(right)
    end

    def self.s_left(tag)
      colored_tag(tag) + space(MAX_LEN - tag_s(tag).size)
    end

    def self.s_right(tag)
      space(MAX_LEN - tag_s(tag).size) + colored_tag(tag)
    end

    def self.colorize(text, code)
      if @color_enabled
        "#{code}#{text}\e[0m"
      else
        text
      end
    end

    def self.red(text)
      colorize(text, "\e[31m")
    end

    def self.green(text)
      colorize(text, "\e[32m")
    end

    def self.yellow(text)
      colorize(text, "\e[33m")
    end

    def self.blue(text)
      colorize(text, "\e[34m")
    end

    public
    def self.color_enabled=(t)
      @color_enabled = t
    end

    def self.split(count = 30)
      puts ''
      puts '-' * count
    end

    def self.tag(s, text = '')
      puts "[#{s_center(s)}] #{text}"
    end

    def self.left(s, text = '')
      puts "[#{s_left(s)}] #{text}"
    end

    def self.right(s, text = '')
      puts "[#{s_right(s)}] #{text}"
    end

  end # class Report
end # module DTest
