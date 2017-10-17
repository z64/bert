module BERT
  # A parser that implements the `Lexer`, mechanizing it to return
  # token values on demand.
  class Parser < Lexer

    # Reads the value from the next token, based on the token's type
    def read_value
      next_token

      case token.type
      when Type::Magic
        # OK
      when Type::Nil
        nil
      when Type::SmallInt
        token.uint_value
      when Type::Integer
        token.int_value
      when Type::Atom
        token.string_value
      when Type::Bin
        token.binary_value
      when Type::Float
        token.float_value
      end
    end

    macro reader(name, method, expected token_type)
      # Advances the lexer, expects the next token to be a {{token_type}},
      # and returns the `Token#{{method}}_value`.
      def read_{{name}}
        next_token
        expect_token {{token_type}}
        token.{{method}}_value
      end
    end

    reader nil, nil, Type::Nil
    reader uint, uint, Type::SmallInt
    reader int, int, Type::Integer
    reader atom, binary,Type::Atom
    reader binary, binary, Type::Bin
    reader float, float, Type::Float

    # Validates the kind of token being parsed
    private def expect_token(token_type)
      raise ParserException.new("Expected #{token_type} but was #{token.type}") unless token.type == token_type
    end
  end
end
