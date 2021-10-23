package tf
empty(value) {
  count(value) == 0
}
non empty(value) {
  count(value) > 0
}
violations {
  non empty(deny)
}
no violations {
  empty(deny)
}
test provider with version is denied {
  input := {
	"provider": { { "version": ">= 3.33.0", "region": "somewhere" } } 
  }
  violations with input as input
}
test provider without version is allowed {
  input := {
    "provider": { { "region": "somewhere" } }
  }
  no violations with input as input
}