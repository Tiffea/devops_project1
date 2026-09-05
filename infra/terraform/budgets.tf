#configure a mail to notify
variable "gmail_for_notifications" {
  description = "mail for AWS notifications"
  type       = string
  sensitive  = true
}

#NOTE - devops1_budget_threshold created cause of unexpected cost of billing at the end of august 2026
#alert notifiator for all the incoming billing
resource "aws_budgets_budget" "devops1_budget_threshold" {
  name         = "aws_budget_alert_messenger"
  budget_type  = "COST"
  limit_amount = "25"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  #no "service" option because the reason is to track cost of all the services


  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 70
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.gmail_for_notifications]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.gmail_for_notifications]
  }
}