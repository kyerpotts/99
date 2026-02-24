-- luacheck: globals describe it assert
local QFixHelpers = require("99.ops.qfix-helpers")
local eq = assert.are.same
local create_entries = QFixHelpers.create_qfix_entries

describe("qfix helpers", function()
  it("parse_line parses filename, line, column, and notes", function()
    local parsed =
      QFixHelpers.parse_line("lua/99/ops/search.lua:42:7,found semantic search")

    eq({
      filename = "lua/99/ops/search.lua",
      lnum = 42,
      col = 7,
      text = "found semantic search",
    }, parsed)
  end)

  it("parse_line keeps commas in notes text", function()
    local parsed = QFixHelpers.parse_line("file.lua:10:3,note,with,commas")

    eq("file.lua", parsed.filename)
    eq(10, parsed.lnum)
    eq(3, parsed.col)
    eq("note,with,commas", parsed.text)
  end)

  it("parse_line returns nil for malformed lines", function()
    eq(nil, QFixHelpers.parse_line("file.lua:10"))
    eq(nil, QFixHelpers.parse_line("file.lua:10:3:extra"))
  end)

  it(
    "parse_line uses defaults for invalid numbers and missing notes",
    function()
      local parsed = QFixHelpers.parse_line("file.lua:notnum:notcol")

      eq({
        filename = "file.lua",
        lnum = 1,
        col = 1,
        text = "",
      }, parsed)
    end
  )

  it(
    "create_qfix_entries parses valid lines and skips malformed ones",
    function()
      local response = table.concat({
        "a.lua:1:2,first hit",
        "not a valid line",
        "b.lua:3:4",
        "c.lua:notnum:notcol,fallback values",
        "",
      }, "\n")

      local locations = create_entries(response)

      eq({
        {
          filename = "a.lua",
          lnum = 1,
          col = 2,
          text = "first hit",
        },
        {
          filename = "b.lua",
          lnum = 3,
          col = 4,
          text = "",
        },
        {
          filename = "c.lua",
          lnum = 1,
          col = 1,
          text = "fallback values",
        },
      }, locations)
    end
  )

  it("create_qfix_entries returns empty list for empty response", function()
    eq({}, create_entries(""))
  end)
end)
