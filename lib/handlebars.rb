class Handlebars
  def compile(input)
  end

  def compile_to_string(input)
  end

  def compile_function_body(input)
  end

  def escape_text
  end

  def escape_expression
  end

  attr_accessor :compiled_partials

  def compile_partials(input)
  end

  def parse_path(input)
  end

  def filter_output(input, escape=true)
  end
end
