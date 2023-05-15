
terraform {
  required_version = ">= 0.13"
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "1.37.2"
    }
  }
}

provider "grafana" {
  oncall_access_token  = "97bf16cfb011a675b6f1ee8e22bd3c4d07e440b2a2953507383a27d6c3f21601"
  insecure_skip_verify = true
  oncall_url           = "http://localhost:8080"
  url                  = "http://localhost:3000"
  auth                 = "admin:admin"
}

resource "grafana_user" "staff" {
  email    = "staff.name@example.com"
  name     = "Staff Name"
  login    = "staff"
  password = "my-password"
  is_admin = false
}
#__________________________________________________
# Create Grafana teams
#__________________________________________________
resource "grafana_team" "team_a" {
  name  = "TeamA"
  email = "teamemail@example.com"
  members = [
    grafana_user.staff.email
  ]
}

resource "grafana_team" "default" {
  name  = "Default"
  email = "default@example.com"
  members = [
  ]
}

#__________________________________________________
# Get grafana oncall team id ( grafana_team.team_a.team_id  or grafana_team.team_a.id does not work)
#__________________________________________________
data "grafana_oncall_team" "team_a" {
  name = grafana_team.team_a.name
}


data "grafana_oncall_team" "default" {
  name = grafana_team.default.name
}

#__________________________________________________
# Create grafana oncall escalation chain
#__________________________________________________
resource "grafana_oncall_escalation_chain" "default" {
  name    = grafana_team.default.name
  team_id = data.grafana_oncall_team.default.id
}

resource "grafana_oncall_escalation_chain" "team_a" {
  name    = grafana_team.team_a.name
  team_id = data.grafana_oncall_team.team_a.id
}
#__________________________________________________
#
#__________________________________________________


resource "grafana_oncall_integration" "alertmanager" {
  name    = "my integration"
  type    = "alertmanager"
  team_id = data.grafana_oncall_team.default.id
  default_route {
    escalation_chain_id = grafana_oncall_escalation_chain.default.id
  }
}



resource "grafana_oncall_route" "default" {
  integration_id      = grafana_oncall_integration.alertmanager.id
  escalation_chain_id = grafana_oncall_escalation_chain.default.id
  routing_regex       = "\"namespace\": \"default\""
  position            = 0
}


resource "grafana_oncall_route" "team_a" {
  integration_id      = grafana_oncall_integration.alertmanager.id
  escalation_chain_id = grafana_oncall_escalation_chain.team_a.id
  routing_regex       = "\"namespace\": \"team_a\""
  position            = 1
}
