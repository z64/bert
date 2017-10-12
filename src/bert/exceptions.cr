module BERT
  # Base error class
  class Error < Exception
  end

  # An error that occured within the `Lexer`
  class LexerException < Error
    # The byte number where the invalid token was read
    getter byte_number : Int32

    def initialize(message, @byte_number = 0)
      super "#{message} at #{@byte_number}"
    end
  end
end
