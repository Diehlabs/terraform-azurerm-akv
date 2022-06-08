locals {
  tags = {
    cost_center       = "01245"
    environment       = "test"
    owner             = "Diehl"
    technical_contact = "Diehl"
  }

  secret_name  = "secret-sauce"
  secret_value = "szechuan"
}
