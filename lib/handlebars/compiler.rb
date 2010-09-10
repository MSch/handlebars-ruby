module Handlebars
  class Compiler
    attr_accessor :string, :pointer, :mustache, :text, :fn, :newlines, :comment, :escaped, :partial, :inverted, :end_condition, :continue_inverted
    def initialize(string)
        @string   = string
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
  end
end
