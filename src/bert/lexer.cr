module BERT
  # A lexer for reading BERT data
  class Lexer
    # The current token the lexer is set on
    getter token = Token.new

    # Fixed float term length
    FLOAT_SIZE = 31

    # The current byte being read
    getter current_byte = 0_i8

    def self.new(string : String)
      new IO::Memory.new(string)
    end

    def self.new(slice : Bytes)
      new IO::Memory.new(slice)
    end

    def initialize(@io : IO)
      @byte_number = 0
      @eof = false
    end

    # Advances the lexer, reading the next token
    def next_token
      token = prefetch_token
      token.used = true
      token
    end

    # Reads the next token, and applies its attributes for the unpacker
    # to handle later
    # TODO: Unhandled types:
    #   - `Fun`
    #   - `NewFun`
    def prefetch_token
      return token unless token.used
      next_byte

      return token if @eof

      begin
        type = token.type = Type.from_value(current_byte)
      rescue
        unexpected_byte!
      end

      case type
      when Type::Magic, Type::Nil
        # OK
      when Type::SmallInt
        token.uint_value = read UInt8
      when Type::Integer
        token.int_value = read Int32
      when Type::SmallTuple
        token.size = read UInt8
      when Type::LargeTuple
        token.size = read UInt16
      when Type::List, Type::Map
        token.size = read UInt32
      when Type::Float
        size = token.size = FLOAT_SIZE
        string_value = consume_string(size)

        if value = string_value.rstrip('\0').to_f?
          token.float_value = value
        else
          raise LexerException.new("Failed to parse Float", @byte_number)
        end
      when Type::Atom
        size = token.size = read UInt16
        token.string_value = consume_string(size)
      when Type::Bin
        size = token.size = read UInt32
        bytes = consume_binary(size)
        token.binary_value = bytes
        token.string_value = String.new(bytes)
      else
        unexpected_byte!
      end

      token
    end

    # Reads the next byte from the IO
    private def next_byte
      @byte_number += 1
      byte = @io.read_byte

      unless byte
        @eof = true
        @token.type = Type::EOF
      end

      token.byte_number = @byte_number
      @current_byte = byte || 0_u8
    end

    # Reads a value from the IO as a Crystal type
    private def read(type : T.class) forall T
      # After reading this type, we'll be `sizeof(T)` bytes further along the IO
      @byte_number += sizeof(T)
      @io.read_bytes(T, IO::ByteFormat::BigEndian)
    end

    # Builds a string from binary values in the IO
    private def consume_string(size)
      String.new(size) do |buffer|
        @io.read_fully(Slice.new(buffer, size))
        @byte_number += size
        {size, 0}
      end
    end

    # Read a binary value from the IO
    private def consume_binary(size)
      bytes = Bytes.new(size)
      @io.read_fully(bytes)
      @byte_number += size
      bytes
    end

    # Raises an expcetion when an unknown token type is read
    def unexpected_byte!
      raise LexerException.new("Unexpected byte", @byte_number)
    end
  end
end
