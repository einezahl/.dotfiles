-- Python snippets, loaded by LuaSnip's Lua loader (see nvim-cmp.lua).
-- Jump between fields with <C-l> / <C-h> in insert mode.
local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

return {
  s(
    { trig = 'def', desc = 'Typed function with docstring' },
    fmt(
      [[
def {}({}) -> {}:
    """{}"""
    {}
]],
      { i(1, 'name'), i(2), i(3, 'None'), i(4, 'Describe what it does.'), i(0, 'pass') }
    )
  ),

  s(
    { trig = 'main', desc = 'main() with __main__ guard' },
    fmt(
      [[
def main() -> None:
    """{}"""
    {}


if __name__ == "__main__":
    main()
]],
      { i(1, 'Entry point.'), i(0, 'pass') }
    )
  ),

  s(
    { trig = 'cli', desc = 'argparse script skeleton' },
    fmt(
      [[
import argparse


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="{}")
    parser.add_argument("{}", type={}, help="{}")
    return parser.parse_args()


def main() -> None:
    """Entry point."""
    args = parse_args()
    {}


if __name__ == "__main__":
    main()
]],
      { i(1, 'What the script does.'), i(2, '--input'), i(3, 'str'), i(4), i(0, 'pass') }
    )
  ),

  s(
    { trig = 'dc', desc = '@dataclass' },
    fmt(
      [[
@dataclass{}
class {}:
    """{}"""

    {}: {}
]],
      { i(1, '(frozen=True)'), i(2, 'Name'), i(3, 'Describe the data.'), i(4, 'field'), i(0, 'int') }
    )
  ),

  s(
    { trig = 'proto', desc = 'typing.Protocol' },
    fmt(
      [[
class {}(Protocol):
    """{}"""

    def {}(self{}) -> {}: ...
]],
      { i(1, 'Name'), i(2, 'Describe the interface.'), i(3, 'method'), i(4), i(0, 'None') }
    )
  ),

  s(
    { trig = 'test', desc = 'pytest test function' },
    fmt(
      [[
def test_{}() -> None:
    """{}"""
    {}
]],
      { i(1, 'name'), i(2, 'Check that ...'), i(0, 'assert True') }
    )
  ),

  s(
    { trig = 'param', desc = 'pytest.mark.parametrize test' },
    fmt(
      [[
@pytest.mark.parametrize(("{}", "{}"), [
    ({}, {}),
])
def test_{}({}: {}, {}: {}) -> None:
    """{}"""
    {}
]],
      {
        i(1, 'value'),
        i(2, 'expected'),
        i(3),
        i(4),
        i(5, 'name'),
        ls.function_node(function(args)
          return args[1][1]
        end, { 1 }),
        i(6, 'int'),
        ls.function_node(function(args)
          return args[1][1]
        end, { 2 }),
        i(7, 'int'),
        i(8, 'Check that ...'),
        i(0, 'assert ...'),
      }
    )
  ),
}
