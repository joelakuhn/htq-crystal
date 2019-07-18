require "myhtml"
require "option_parser"

module HTQ

  class Config

    property pretty = false
    property css_queries = [] of String
    property plaintext = false
    property attrs = [] of String

  end

  config = Config.new()
  files = [] of String

  OptionParser.parse(ARGV) do |parser|

    parser.banner = "usage: htq [files] [options]"

    parser.on("-c QUERY", "--css=QUERY", "Specify a css query") do |query|
      config.css_queries.push(query)
    end

    parser.on("-p", "--pretty", "Pretty print output") do
      config.pretty = true
    end

    parser.on("-t", "--text", "Print text content") do
      config.plaintext = true
    end

    parser.on("-a ATTR", "--attr=ATTR", "Extract an attribute value") do |attr|
      config.attrs.push(attr)
    end

    parser.on("-h", "--help", "Print help message") do
      puts parser.to_s
      exit();
    end

    parser.unknown_args do |positional_args|
      files = positional_args
    end

  end

  def self.process_input(input, config)

    dom = Myhtml::Parser.new(input)

    if config.css_queries.empty? && config.pretty

      puts dom.to_pretty_html

    else

      config.css_queries.each do |query|

        dom.css(query).each do |el|
          if config.pretty
            puts el.to_pretty_html
          elsif ! config.attrs.empty?
            config.attrs.each do |attr|
              if el.attributes.has_key?(attr)
                puts el.attributes[attr]
              end
            end
          elsif config.plaintext
            puts el.inner_text
          else
            print el.to_html
          end
        end

      end

    end

  end

  if files.empty?

    process_input(STDIN.gets_to_end(), config)

  else

    files.each do |file|
      begin
        if file == "-"
          input = STDIN.gets_to_end()
        else
          input = File.read(file)
        end
        process_input(input, config)
      rescue exception
        STDERR.puts exception
      end
    end

  end

end
