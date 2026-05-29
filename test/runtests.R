source(file.path("src", "donor_cohort_risk_lab.R"))

result <- build_dashboard()

stopifnot(result$total_donors > 0)
stopifnot(result$avg_retention_delta_pct > 0)
stopifnot(nrow(result$lane_results) == 4)
stopifnot(any(result$lane_results$status == "red"))
stopifnot(all(c("cohort", "actual_retention_pct", "risk_score") %in% names(result$lane_results)))

cat("All tests passed.\n")
