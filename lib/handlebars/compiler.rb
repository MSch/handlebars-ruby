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


    end

  end
end
