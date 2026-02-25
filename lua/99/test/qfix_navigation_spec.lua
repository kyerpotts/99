-- luacheck: globals describe it assert before_each
local _99 = require("99")
local test_utils = require("99.test.test_utils")
local eq = assert.are.same

local content = {
  "local value = 1",
  "return value",
}

local function qfix_first_text()
  local items = vim.fn.getqflist()
  local first = items[1]
  assert(first, "expected a quickfix item")
  return first.text
end

describe("qfix navigation", function()
  local provider
  local results = {}

  before_each(function()
    provider = test_utils.test_setup(content, 1, 0)
  end)

  it("navigates older and newer search quickfix results", function()
    _99.search({ additional_prompt = "search one" })
    provider:resolve("success", "/tmp/one.lua:1:1,1,first search")
    test_utils.next_frame()

    _99.search({ additional_prompt = "search two" })
    provider:resolve("success", "/tmp/two.lua:1:1,1,second search")
    test_utils.next_frame()

    _99.search({ additional_prompt = "search three" })
    provider:resolve("success", "/tmp/three.lua:1:1,1,third search")
    test_utils.next_frame()

    _99.qfix_older({ operation = "search" })
    eq("second search", qfix_first_text())

    _99.qfix_older({ operation = "search" })
    eq("first search", qfix_first_text())

    _99.qfix_newer({ operation = "search" })
    eq("second search", qfix_first_text())

    _99.qfix_top({ operation = "search" })
    eq("third search", qfix_first_text())
  end)

  it("navigates vibe quickfix history through vibe results", function()
    _99.vibe({ additional_prompt = "vibe one" })
    provider:resolve("success", "/tmp/a.lua:1:1,1,first vibe")
    test_utils.next_frame()

    _99.vibe({ additional_prompt = "vibe two" })
    provider:resolve("success", "/tmp/b.lua:1:1,1,second vibe")
    test_utils.next_frame()

    _99.qfix_top({ operation = "vibe" })
    eq("second vibe", qfix_first_text())

    _99.qfix_older({ operation = "vibe" })
    eq("first vibe", qfix_first_text())

    _99.qfix_newer({ operation = "vibe" })
    eq("second vibe", qfix_first_text())
  end)
end)
