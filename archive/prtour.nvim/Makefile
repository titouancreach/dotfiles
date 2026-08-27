.PHONY: test live ui

# Unit + render smoke tests (no network).
test:
	nvim --headless -l tests/run.lua

# Live parse + AI tour generation against a diff fixture:
#   make live DIFF=/path/to.diff
live:
	nvim --headless -l tests/live.lua $(DIFF)

# UI render smoke test against a diff fixture:
#   make ui DIFF=/path/to.diff
ui:
	nvim --headless -l tests/ui.lua $(DIFF)
