def print_tool

  Prawn::Document.generate('hello.pdf') do |pdf|
    pdf.text("Hello Prawn!")
  end
end

