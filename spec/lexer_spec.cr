require "./spec_helper"

private def it_lexes_type(expected_type, bytes, file = __FILE__, line = __LINE__)
  slice = Bytes.new(bytes.to_unsafe, bytes.size)

  it "lexes #{expected_type} from IO", file, line do
    lexer = Lexer.new(slice)
    token = lexer.next_token
    token.type.should eq(expected_type)
  end
end

private def it_lexes_type_with_value(expected_type, value, bytes, file = __FILE__, line = __LINE__)
  slice = Bytes.new(bytes.to_unsafe, bytes.size)

  it "lexes #{expected_type} from IO", file, line do
    lexer = Lexer.new(slice)
    token = lexer.next_token
    token.type.should eq(expected_type)
    case expected_type
    when Type::SmallInt
      token.uint_value.should eq(value)
    when Type::Integer
      token.int_value.should eq(value)
    when Type::Atom
      token.string_value.should eq(value)
    when Type::Bin
      token.binary_value.should eq(value)
    when Type::Float
      token.float_value.should eq(value)
    when Type::SmallTuple, Type::LargeTuple, Type::List
      token.size.should eq(value)
    end
  end
end

describe Lexer do
  # Basic terms
  it_lexes_type(Type::EOF, UInt8[])
  it_lexes_type(Type::Magic, UInt8[131])
  it_lexes_type(Type::Nil, UInt8[106])

  # Single value terms
  it_lexes_type_with_value(Type::SmallInt, UInt8::MAX, UInt8[97, 255])
  it_lexes_type_with_value(Type::Integer, Int32::MAX, UInt8[98, 127, 255, 255, 255])
  it_lexes_type_with_value(Type::Atom, "abc", UInt8[100, 0, 3, 97, 98, 99])
  it_lexes_type_with_value(Type::Bin, Bytes[1, 2, 3], UInt8[109, 0, 0, 0, 3, 1, 2, 3])
  it_lexes_type_with_value(Type::Float, 1.234, UInt8[99, 49, 46, 50, 51, 52, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 101, 43, 48, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

  # Complex terms
  it_lexes_type_with_value(Type::SmallTuple, 3, UInt8[104, 3])
  it_lexes_type_with_value(Type::LargeTuple, 3, UInt8[105, 0, 3])
  it_lexes_type_with_value(Type::List, 3, UInt8[108, 0, 0, 0, 3])
  it_lexes_type_with_value(Type::Map, 3, UInt8[116, 0, 0, 0, 3])
end
