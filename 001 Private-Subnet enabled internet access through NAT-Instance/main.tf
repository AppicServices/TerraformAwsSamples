#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Configure the AWS Provider
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region  = var.Region 
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Common Variables
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Default Region
variable "Region" {
  default = "eu-central-1" # momentan fest auf Frankfurt.
  type = string 
}

# Availability-Zone 1
variable "AZ1" {
  default = "a"
  type = string
}

# Availability-Zone 2
variable "AZ2" {
  default = "b"
  type = string
}

# Für die Auslieferung und Benennung
variable "ProjectName" {
  default = "NatExample"
  type = string
}

