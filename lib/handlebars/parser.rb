require 'strscan'

class Handlebars
  class Parser
    # A SyntaxError is raised when the Parser comes across unclosed
    # tags, sections, illegal content in tags, or anything of that
    # sort.
    class SyntaxError < StandardError
      def initialize(message, position)
        @message = message
        @lineno, @column, @line = position
        @stripped_line = @line.strip
        @stripped_column = @column - (@line.size - @line.lstrip.size)
      end

      def to_s
        <<-EOF
#{@message}
  Line #{@lineno}
    #{@stripped_line}
    #{' ' * @stripped_column}^
EOF
      end
    end

    # After these types of tags, all whitespace will be skipped.
    SKIP_WHITESPACE = [ '#', '^', '/' ]

    # The content allowed in a tag name.
    ALLOWED_CONTENT = /(\w|[.?!\/-])*/

    # These types of tags allow any content,
    # the rest only allow ALLOWED_CONTENT.
    ANY_CONTENT = [ '!', '=' ]

    attr_reader :scanner, :result
    attr_writer :otag, :ctag

    # Accepts an options hash which does nothing but may be used in
    # the future.
    def initialize(options = {})
      @options = {}
    end

    # The opening tag delimiter. This may be changed at runtime.
    def otag
      @otag ||= '{{'
    end

    # The closing tag delimiter. This too may be changed at runtime.
    def ctag
      @ctag ||= '}}'
    end

    # Given a string template, returns an array of tokens.
    def compile(template)
      if template.respond_to?(:encoding)
        @encoding = template.encoding
        template = template.dup.force_encoding("BINARY")
      else
        @encoding = nil
      end

      # Keeps information about opened sections.
      @sections = []
      @result = [:multi]
      @scanner = StringScanner.new(template)

      # Scan until the end of the template.
      until @scanner.eos?
        scan_tags || scan_text
      end

      if !@sections.empty?
        # We have parsed the whole file, but there's still opened sections.
        type, pos, result = @sections.pop
        error "Unclosed section #{type.inspect}", pos
      end

      @result
    end

    # Find {{mustaches}} and add them to the @result array.
    def scan_tags
      # Scan until we hit an opening delimiter.
      return unless @scanner.scan(regexp(otag))

      # Since {{= rewrites ctag, we store the ctag which should be used
      # when parsing this specific tag.
      current_ctag = self.ctag
      type = @scanner.scan(/#|\^|\/|=|!|<|>|&|\{/)
      @scanner.skip(/\s*/)

      # ANY_CONTENT tags allow any character inside of them, while
      # other tags (such as variables) are more strict.
      if ANY_CONTENT.include?(type)
        r = /\s*#{regexp(type)}?#{regexp(current_ctag)}/
        content = scan_until_exclusive(r)
      else
        content = @scanner.scan(ALLOWED_CONTENT)
      end

      # We found {{ but we can't figure out what's going on inside.
      error "Illegal content in tag" if content.empty?

      # Based on the sigil, do what needs to be done.
      case type
      when '#'
        block = [:multi]
        @result << [:mustache, :section, content, block]
        @sections << [content, position, @result]
        @result = block
      when '^'
        block = [:multi]
        @result << [:mustache, :inverted_section, content, block]
        @sections << [content, position, @result]
        @result = block
      when '/'
        section, pos, result = @sections.pop
        @result = result

        if section.nil?
          error "Closing unopened #{content.inspect}"
        elsif section != content
          error "Unclosed section #{section.inspect}", pos
        end
      when '!'
        # ignore comments
      when '='
        self.otag, self.ctag = content.split(' ', 2)
      when '>', '<'
        @result << [:mustache, :partial, content]
      when '{', '&'
        # The closing } in unescaped tags is just a hack for
        # aesthetics.
        type = "}" if type == "{"
        @result << [:mustache, :utag, content]
      else
        @result << [:mustache, :etag, content]
      end

      # Skip whitespace and any balancing sigils after the content
      # inside this tag.
      @scanner.skip(/\s+/)
      @scanner.skip(regexp(type)) if type

      # Try to find the closing tag.
      unless close = @scanner.scan(regexp(current_ctag))
        error "Unclosed tag"
      end

      # Skip whitespace following this tag if we need to.
      @scanner.skip(/\s+/) if SKIP_WHITESPACE.include?(type)
    end

    # Try to find static text, e.g. raw HTML with no {{mustaches}}.
    def scan_text
      text = scan_until_exclusive(regexp(otag))

      if text.nil?
        # Couldn't find any otag, which means the rest is just static text.
        text = @scanner.rest
        # Mark as done.
        @scanner.clear
      end

      text.force_encoding(@encoding) if @encoding

      @result << [:static, text]
    end

    # Scans the string until the pattern is matched. Returns the substring
    # *excluding* the end of the match, advancing the scan pointer to that
    # location. If there is no match, nil is returned.
    def scan_until_exclusive(regexp)
      pos = @scanner.pos
      if @scanner.scan_until(regexp)
        @scanner.pos -= @scanner.matched.size
        @scanner.pre_match[pos..-1]
      end
    end

    # Returns [lineno, column, line]
    def position
      # The rest of the current line
      rest = @scanner.check_until(/\n|\Z/).to_s.chomp

      # What we have parsed so far
      parsed = @scanner.string[0...@scanner.pos]

      lines = parsed.split("\n")

      [ lines.size, lines.last.size - 1, lines.last + rest ]
    end

    # Used to quickly convert a string into a regular expression
    # usable by the string scanner.
    def regexp(thing)
      /#{Regexp.escape(thing)}/
    end

    # Raises a SyntaxError. The message should be the name of the
    # error - other details such as line number and position are
    # handled for you.
    def error(message, pos = position)
      raise SyntaxError.new(message, pos)
    end
  end
end

