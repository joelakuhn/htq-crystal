require "myhtml"
require "option_parser"
require "xml"

module HTQ

  class Options

    property pretty = false
    property css_queries = [] of String
    property plaintext = false
    property attrs = [] of String
    property xpaths = [] of String

  end

  options = Options.new()
  files = [] of String

  OptionParser.parse(ARGV) do |parser|

    parser.banner = "usage: htq [files] [options]"

    parser.on("-c QUERY", "--css=QUERY", "Specify a css selector") do |query|
      options.css_queries.push(query)
    end

    parser.on("-x XPATH", "--xpath=XPATH", "Specify an XPATH selector") do |xpath|
      options.xpaths.push(xpath)
    end

    parser.on("-p", "--pretty", "Pretty print output") do
      options.pretty = true
    end

    parser.on("-t", "--text", "Print text content") do
      options.plaintext = true
    end

    parser.on("-a ATTR", "--attr=ATTR", "Extract an attribute value") do |attr|
      options.attrs.push(attr)
    end

    parser.on("-h", "--help", "Print help message") do
      puts parser.to_s
      exit();
    end

    parser.unknown_args do |positional_args|
      files = positional_args
    end

  end

  def self.prettify(input, options)
    dom = Myhtml::Parser.new(input)
    puts dom.to_pretty_html
  end

  def self.process_css_queries(input, options)

    dom = Myhtml::Parser.new(input)
    options.css_queries.each do |query|
      dom.css(query).each do |el|
        if options.pretty
          puts el.to_pretty_html
        elsif ! options.attrs.empty?
          options.attrs.each do |attr|
            if el.attributes.has_key?(attr)
              puts el.attributes[attr]
            end
          end
        elsif options.plaintext
          puts el.inner_text
        else
          print el.to_html
        end
      end
    end
  end

  def self.process_xpath_queries(input, options)
    dom = XML.parse_html(input, XML::HTMLParserOptions::RECOVER)

    options.xpaths.each do |xpath|
      result = dom.xpath(xpath)
      if result.is_a?(XML::NodeSet)
        result.each do |node|
          if options.pretty
            puts node.to_xml(indent: 2)
          else
            puts node.to_s()
          end
        end
      else
        puts result
      end
    end
  end

  def self.process_input(input, options)

    unless options.xpaths.empty?
      self.process_xpath_queries(input, options)
    end

    unless options.css_queries.empty?
      self.process_css_queries(input, options)
    end

    if options.xpaths.empty? && options.css_queries.empty?
      if options.pretty
        self.prettify(input, options)
      else
        puts input
      end
    end

  end

  if files.empty?

    process_input(STDIN.gets_to_end(), options)

  else

    files.each do |file|
      begin
        if file == "-"
          input = STDIN.gets_to_end()
        else
          input = File.read(file)
        end
        process_input(input, options)
      rescue exception
        STDERR.puts exception
      end
    end

  end

end
