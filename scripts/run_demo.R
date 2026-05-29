source(file.path("src", "donor_cohort_risk_lab.R"))

result <- build_dashboard()

cat("Donor cohort risk lab\n")
cat("=====================\n")
cat(sprintf("Total donors: %s\n", result$total_donors))
cat(sprintf("Escalated cohorts: %s\n", result$escalated_cohorts))
cat(sprintf("Average retention delta: %s pts\n", result$avg_retention_delta_pct))
cat(sprintf("Average upgrade delta: %s pts\n", result$avg_upgrade_delta_pct))
cat(sprintf("Average recency gap: %s days\n", result$avg_recency_gap_days))
cat("\nHighest-priority cohort queue:\n")
print(result$action_queue, row.names = FALSE)
