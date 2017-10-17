module BERT
  # Base error class
  class Error < Exception
  end

  # An error that occured within the `Lexer`
  class UnpackingException < Error
    # The byte number where the invalid token was read
    getter byte_number : Int32

    def initialize(message, @byte_number = 0)
      super "#{message} at #{@byte_number}"
    end
  end

  # An exception within the lexer
  class LexerException < UnpackingException
  end

  # An exception within the parser
  class ParserException< UnpackingException
  end
end
