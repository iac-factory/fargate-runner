resource "random_uuid" "uuid" {
    count = var.uuid ? 1 : 0
}
