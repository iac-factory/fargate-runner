output "uuid" {
    sensitive = false

    description = "UUIDv4 Generated Identifier"
    value = random_uuid.uuid
}

output "password" {
    sensitive = true

    description = "A Randomly Generated Password"
    value = try(random_password.password[0].result, null)
}
