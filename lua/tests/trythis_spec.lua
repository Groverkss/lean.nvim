local helpers = require('tests.helpers')

require('lean').setup { lsp3 = { enable = true } }

describe('trythis', function()
  it('replaces a single try this', helpers.clean_buffer("lean3", [[
meta def whatshouldIdo := (do tactic.trace "Try this: existsi 2; refl\n")
example : ∃ n, n = 2 := by whatshouldIdo]], function()
    vim.api.nvim_command('normal G$')
    helpers.wait_for_line_diagnostics()

    require('lean.trythis').swap()
    assert.is.same(
      'example : ∃ n, n = 2 := by existsi 2; refl',
      vim.api.nvim_get_current_line()
    )
  end))

  it('replaces a single try this from by', helpers.clean_buffer("lean3", [[
meta def whatshouldIdo := (do tactic.trace "Try this: existsi 2; refl\n")
example : ∃ n, n = 2 := by whatshouldIdo]], function()
    vim.api.nvim_command('normal G$bb')
    helpers.wait_for_line_diagnostics()

    require('lean.trythis').swap()
    assert.is.same(
      'example : ∃ n, n = 2 := by existsi 2; refl',
      vim.api.nvim_get_current_line()
    )
  end))

  it('replaces a single try this from earlier in the line', helpers.clean_buffer("lean3", [[
meta def whatshouldIdo := (do tactic.trace "Try this: existsi 2; refl\n")
example : ∃ n, n = 2 := by whatshouldIdo]], function()
    vim.api.nvim_command('normal G0')
    helpers.wait_for_line_diagnostics()

    require('lean.trythis').swap()
    assert.is.same(
      'example : ∃ n, n = 2 := by existsi 2; refl',
      vim.api.nvim_get_current_line()
    )
  end))

  it('replaces a try this with even more unicode', helpers.clean_buffer("lean3", [[
meta def whatshouldIdo := (do tactic.trace "Try this: existsi 0; intro m; refl")
example : ∃ n : nat, ∀ m : nat, m = m := by whatshouldIdo]], function()
    vim.api.nvim_command('normal G$')
    helpers.wait_for_line_diagnostics()

    require('lean.trythis').swap()
    assert.is.same(
      'example : ∃ n : nat, ∀ m : nat, m = m := by existsi 0; intro m; refl',
      vim.api.nvim_get_current_line()
    )
  end))

  -- Emitted by e.g. hint
  -- luacheck: ignore
  it('replaces squashed together try this messages', helpers.clean_buffer("lean3", [[
meta def whatshouldIdo := (do tactic.trace "the following tactics solve the goal\n---\nTry this: finish\nTry this: tauto\n")
example : ∃ n, n = 2 := by whatshouldIdo]], function()
    vim.api.nvim_command('normal G$')
    helpers.wait_for_line_diagnostics()

    require('lean.trythis').swap()
    assert.is.same(
      'example : ∃ n, n = 2 := by finish',
      vim.api.nvim_get_current_line()
    )
  end))

  -- Emitted by e.g. pretty_cases
  it('replaces multiline try this messages', helpers.clean_buffer("lean3", [[
meta def whatshouldIdo := (do tactic.trace "Try this: existsi 2,\n  refl,\n")
example : ∃ n, n = 2 := by {
  whatshouldIdo
}]], function()
    vim.api.nvim_command('normal 3gg$')
    helpers.wait_for_line_diagnostics()

    require('lean.trythis').swap()
    assert.contents.are[[
meta def whatshouldIdo := (do tactic.trace "Try this: existsi 2,\n  refl,\n")
example : ∃ n, n = 2 := by {
  existsi 2,
  refl,
}]]
  end))

  -- Emitted by e.g. library_search
  it('trims by exact foo to just foo', helpers.clean_buffer("lean3", [[
meta def whatshouldIdo := (do tactic.trace "Try this: exact rfl")
example {n : nat} : n = n := by whatshouldIdo]], function()
    vim.api.nvim_command('normal G$')
    helpers.wait_for_line_diagnostics()

    require('lean.trythis').swap()
    assert.is.same(
      'example {n : nat} : n = n := rfl',
      vim.api.nvim_get_current_line()
    )
  end))

  it('replaces squashed suggestions from earlier in the line', helpers.clean_buffer("lean3", [[
meta def whatshouldIdo := (do tactic.trace "Try this: exact rfl")
example {n : nat} : n = n := by whatshouldIdo]], function()
    vim.api.nvim_command('normal G0')
    helpers.wait_for_line_diagnostics()

    require('lean.trythis').swap()
    assert.is.same(
      'example {n : nat} : n = n := rfl',
      vim.api.nvim_get_current_line()
    )
  end))
end)
