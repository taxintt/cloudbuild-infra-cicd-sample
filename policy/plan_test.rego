package plan

warning[msg] {
	changes := input.resource_changes[_]

	changes.type = "google project iam member"
	changes[_].after.role == "roles/admin"

	is_production(changes[_].after.project)
	msg := "Admin role is not allowed in prod because of zero touch production."
}

is_production(project) {
   endswith(project, "prod")
}