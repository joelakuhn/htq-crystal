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
    property print0 = false
    property list_files = false
    property nonl = false

  end

  options = Options.new()
  files = [] of String
  @@puts_lock = Mutex.new()

  OptionParser.parse(ARGV) do |parser|

    parser.banner = "usage: htq [css_query] [options] [file ...]"

    parser.on("-c QUERY", "--css=QUERY", "Specify a css selector") do |query|
      options.css_queries.push(query)
    end

    parser.on("-x XPATH", "--xpath=XPATH", "Specify an XPATH selector") do |xpath|
      options.xpaths.push(xpath)
    end

    parser.on("-a ATTR", "--attr=ATTR", "Extract an attribute value") do |attr|
      options.attrs.push(attr)
    end

    parser.on("-p", "--pretty", "Pretty print output") do
      options.pretty = true
    end

    parser.on("-t", "--text", "Print text content") do
      options.plaintext = true
    end

    parser.on("-0", "--print0", "Separate output by NULL") do
      options.print0 = true
    end

    parser.on("-l", "--list-files", "List matching files without matches") do
      options.list_files = true;
    end

    parser.on("-n", "--nonl", "Remove newlines from matches") do
      options.nonl = true;
    end

    parser.invalid_option do |option|
      puts "#{option} is not a valid option\n\n"
      puts parser.to_s
      exit();
    end

    parser.on("-h", "--help", "Print help message") do
      puts parser.to_s
      exit();
    end

    parser.unknown_args do |positional_args|
      if options.css_queries.empty? && options.xpaths.empty?
        options.css_queries.push(positional_args.shift())
      end
      files = positional_args
    end

    if ARGV.empty?
      puts parser.to_s
      exit();
    end

  end

  def self.emit(output, options)
    if options.nonl
      output = output.gsub(/\r?\n/, " ")
    end
    @@puts_lock.synchronize do
      if options.print0
        print "#{output}\0"
      else
        puts output
      end
    end
  end

  def self.prettify(input, options)
    dom = Myhtml::Parser.new(input)
    return dom.to_pretty_html
  end

  def self.process_css_queries(file, input, options)

    dom = Myhtml::Parser.new(input)
    options.css_queries.each do |query|
      result = dom.css(query)

      if options.list_files && result.any?
        return file
      end

      result.each do |el|
        if options.pretty
          return el.to_pretty_html
        elsif ! options.attrs.empty?
          options.attrs.each do |attr|
            if el.attributes.has_key?(attr)
              return el.attributes[attr]
            end
          end
        elsif options.plaintext
          return el.inner_text
        else
          return el.to_html
        end
      end
    end
  end

  def self.process_xpath_queries(file, input, options)
    dom = XML.parse_html(input, XML::HTMLParserOptions::RECOVER)

    options.xpaths.each do |xpath|
      result = dom.xpath(xpath, [ { "wp", "http://wordpress.org/export/1.2/" } ])

      if options.list_files
        if (result.is_a?(XML::NodeSet) && result.any?) || ! result.is_a?(XML::NodeSet)
          return file;
        end
      end

      if result.is_a?(XML::NodeSet)
        result.each do |node|
          if options.pretty
            return node.to_xml(indent: 2);
          elsif options.plaintext
            return node.content;
          else
            return node.to_s();
          end
        end
      else
        return result.to_s;
      end
    end
  end

  def self.process_input(channel, file, input, options)

    unless options.xpaths.empty?
      channel.send self.process_xpath_queries(file, input, options)
    end

    unless options.css_queries.empty?
      channel.send self.process_css_queries(file, input, options)
    end

    if options.xpaths.empty? && options.css_queries.empty?
      if options.pretty
        channel.send prettify(input, options)
      else
        channel.send input
      end
    end

  end

  channel = Channel(String|Nil).new

  if files.empty?

    process_input(channel, "STDIN", STDIN.gets_to_end(), options)

  else

    files.each do |file|
      spawn do
        begin
          if file == "-"
            input = STDIN.gets_to_end()
          else
            input = File.read(file)
          end
          process_input(channel, file, input, options)
        rescue exception
          STDERR.puts exception
        end
      end
    end

    files.size.times do
      result = channel.receive()
      unless result.nil?
        emit(result, options)
      end
    end

  end

end
