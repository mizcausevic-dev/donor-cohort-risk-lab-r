source(file.path("src", "donor_cohort_risk_lab.R"))

dir.create("screenshots", showWarnings = FALSE, recursive = TRUE)
result <- build_dashboard()

svg_wrap <- function(text, width = 44) {
  parts <- strwrap(text, width = width)
  if (length(parts) == 0) {
    return("")
  }
  paste(parts, collapse = "\n")
}

write_svg_card <- function(path, eyebrow, title, lines, accent = "#19c7ff") {
  y <- 138
  body <- c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="900" viewBox="0 0 1600 900">',
    '  <defs>',
    '    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">',
    '      <stop offset="0%" stop-color="#0b1220"/>',
    '      <stop offset="100%" stop-color="#08101d"/>',
    '    </linearGradient>',
    '  </defs>',
    '  <rect width="1600" height="900" fill="#05070c"/>',
    '  <rect x="48" y="48" width="1504" height="804" rx="30" fill="url(#bg)" stroke="#17324d" stroke-width="2"/>',
    sprintf('  <text x="96" y="118" fill="%s" font-family="ui-monospace,Consolas,monospace" font-size="26" letter-spacing="6">%s</text>', accent, html_escape(toupper(eyebrow))),
    sprintf('  <text x="96" y="196" fill="#f2f7ff" font-family="Georgia,Times New Roman,serif" font-size="62" font-weight="700">%s</text>', html_escape(title))
  )

  for (block in lines) {
    wrapped <- strsplit(svg_wrap(block), "\n", fixed = TRUE)[[1]]
    body <- c(body, sprintf('  <text x="96" y="%d" fill="#b8c9df" font-family="Segoe UI,Arial,sans-serif" font-size="30">', y))
    for (i in seq_along(wrapped)) {
      dy <- if (i == 1) 0 else 40
      body <- c(body, sprintf('    <tspan x="96" dy="%d">%s</tspan>', dy, html_escape(wrapped[[i]])))
    }
    body <- c(body, '  </text>')
    y <- y + (length(wrapped) * 40) + 34
  }

  body <- c(body, '</svg>')
  writeLines(body, path, useBytes = TRUE)
}

overview_lines <- c(
  sprintf("Total donors: %s · average retention delta: %s points · average recency gap: %s days.", result$total_donors, result$avg_retention_delta_pct, result$avg_recency_gap_days),
  sprintf("Escalated cohorts: %s.", paste(result$lane_results$cohort[result$lane_results$status == "red"], collapse = ", ")),
  "The operator surface keeps retention drift, upgrade softness, recency slippage, and stewardship gaps visible in one proof set."
)

lane_lines <- apply(result$lane_results[, c("cohort", "channel", "risk_score", "status")], 1, function(row) {
  sprintf("%s · %s · risk score %s · %s", row[[1]], row[[2]], row[[3]], toupper(row[[4]]))
})

posture_lines <- c(
  "Appeal posture flags where retention, upgrade, or stewardship drift is already pulling a cohort outside expected fundraising guardrails.",
  paste(sprintf("%s: %s", result$action_queue$cohort, result$action_queue$recommendation), collapse = " | ")
)

verification_lines <- c(
  "Proof assets are generated from the same base-R scenario and analysis functions used for the dashboard routes.",
  "Routes: / · /cohort-lane/ · /retention-matrix/ · /appeal-posture/ · /verification/ · /docs/."
)

write_svg_card("screenshots/01-overview.svg", "donor cohort risk lab r", "Donor cohort risk lab for retention and appeal posture.", overview_lines)
write_svg_card("screenshots/02-cohort-lane.svg", "cohort lane", "Fundraising cohorts with the most donor drift stay visible.", lane_lines, accent = "#37ff8b")
write_svg_card("screenshots/03-appeal-posture.svg", "appeal posture", "Stewardship and retention gaps stay buyer-readable.", posture_lines, accent = "#ffcc66")
write_svg_card("screenshots/04-verification.svg", "verification", "Base-R analysis and static proof routes stay in sync.", verification_lines, accent = "#b88cff")

cat("Rendered README assets.\n")
