eq(1, 1, "harness")
local BP = newBP()
truthy(BP.db and BP.db.profile, "AceDB loads on the stubs")
