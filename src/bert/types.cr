module BERT
  # Identities of BERT tags
  enum Type
    None
    EOF
    SmallInt   =  97
    Integer    =  98
    Float      =  99
    Atom       = 100
    SmallTuple = 104
    LargeTuple = 105
    Nil        = 106
    String     = 107
    List       = 108
    Bin        = 109
    Map        = 116

    # TODO: OwO what's this?
    Fun = 117

    # TODO: OwO what's this?
    NewFun = 112

    Magic  = 131
    MaxInt = (1 << 27) - 1
    MinInt = -(1 << 27)
  end
end
