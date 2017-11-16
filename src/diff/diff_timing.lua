require("diff")
require("../utils/tablemerge")

Diff.defaults_timing = {
    useGameTime = true
}

Diff.external_timing = {
	useGameTime = true
}

table.merge(Diff.defaults, Diff.defaults_timing)
table.merge(Diff.external, Diff.external_timing)
