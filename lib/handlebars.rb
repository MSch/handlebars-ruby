class Handlebars
  attr_accessor :compiled_partials
  def compile(input)
  end

  def compile_to_string(input)
  end

  def compile_function_body(input)
  end

  def escape_text(input)
    CGI.escapeHTML(input)
  end

  def escape_expression(input)
  end


  def compile_partials(input)
  end

  def parse_path(input)
  end

  def filter_output(input, escape=true)
  end
end
