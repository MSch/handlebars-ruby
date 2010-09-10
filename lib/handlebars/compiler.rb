require 'stringio'

class Handlebars
  class Compiler
    attr_accessor :input, :pointer, :mustache, :text, :fn, :newlines, :comment, :escaped, :partial, :inverted, :end_condition, :continue_inverted
    def initialize(input)
      @input   = input
      @pointer  = -1
      @mustache = false
      @text     = ''
      @fn       = 'out = ""; lookup = nil; '
      @newlines = ''
      @comment  = false
      @escaped  = true
      @partial  = false
      @inverted = false
      @end_condition = nil
      @continue_inverted = false
    end

    def add_text
     if not @text.empty?
       @fn << 'out = out + \'' + CGI.escapeHTML(@text) + '\''
       @fn << @newlines
       @newlines = ''
       @text = ''
     end
    end

    def parse_mustache
      chr, part, mustache, param = nil
      @s = StringScanner.new(input)

      next_char = @s.peek
      case next_char
      when '!'
        @comment = true
      when '#'
        @open_block = true
      when '>'
        @partial = true
      when '^'
        @inverted = true
        @open_block = true
      when '{'
        @escaped = false
      when '&'
        @escaped = false
      end
      @s.getch

      add_text
      @mustache = ' '

      while(chr = @s.getch)
        if @mustache && chr == '}' && @s.peek == '}'
          parts = @mustache.chomp.split(/\s+/)
          mustache = parts[0]
          param = lookup_for(parts[1])

          @mustace = false

          # finish reading off the close of the handlebars
          @s.getch

        # {{{expression}} is techically valid, but if we started with {{{ we'll try to read 
        # }}} off of the close of the handlebars
          @s.getch if (!@escaped && @s.peek == '}')

          if @comment
            @comment = false
            return
          elsif @partial
            add_partial(mustache, param)
            return
          elsif @inverted
            add_inverted_section(mustache)
            return
          elsif @open_block
            add_block(mustache, param, parts)
            return
          else
            return this.add_expression(mustache, param)
          end

          @escaped = true
        elsif @comment
          ;
        else
          @mustace << chr
        end
      end
    end

  end
end
