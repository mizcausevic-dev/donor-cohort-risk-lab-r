source(file.path("src", "donor_cohort_risk_lab.R"))

result <- build_dashboard()
write_site(result)
cat("Generated site at", normalizePath("site", winslash = "/", mustWork = FALSE), "\n")
