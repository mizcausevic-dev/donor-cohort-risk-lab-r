# SPDX-License-Identifier: AGPL-3.0-or-later

html_escape <- function(text) {
  text <- as.character(text)
  text <- gsub("&", "&amp;", text, fixed = TRUE)
  text <- gsub("<", "&lt;", text, fixed = TRUE)
  text <- gsub(">", "&gt;", text, fixed = TRUE)
  text <- gsub('"', "&quot;", text, fixed = TRUE)
  text
}

sample_scenario <- function() {
  data.frame(
    lane_id = c("DC-08", "DC-14", "DC-22", "DC-37"),
    cohort = c("Monthly sustainers", "Mid-level annual", "Lapsed major", "First-year digital"),
    channel = c("Email + direct debit", "Events + outbound", "Portfolio stewardship", "Paid social + email"),
    donors = c(1840, 520, 74, 2360),
    expected_retention_pct = c(88, 72, 46, 39),
    actual_retention_pct = c(81, 64, 31, 29),
    expected_upgrade_pct = c(12, 18, 9, 4),
    actual_upgrade_pct = c(8, 12, 3, 2),
    concentration_risk_pct = c(9, 18, 41, 6),
    recency_gap_days = c(11, 18, 47, 22),
    stewardship_gaps = c(3, 6, 8, 5),
    stringsAsFactors = FALSE
  )
}

analyze_donor_risk <- function(scenario = sample_scenario()) {
  retention_delta_pct <- round(scenario$expected_retention_pct - scenario$actual_retention_pct, 1)
  upgrade_delta_pct <- round(scenario$expected_upgrade_pct - scenario$actual_upgrade_pct, 1)
  risk_score <- round((pmax(retention_delta_pct, 0) * 3) + (pmax(upgrade_delta_pct, 0) * 2) + (scenario$concentration_risk_pct * 0.8) + (scenario$recency_gap_days * 0.4) + (scenario$stewardship_gaps * 2))

  status <- ifelse(
    risk_score >= 65 | retention_delta_pct >= 10 | scenario$concentration_risk_pct >= 35,
    "red",
    ifelse(risk_score >= 35 | retention_delta_pct >= 5 | scenario$recency_gap_days >= 20, "yellow", "green")
  )

  recommendation <- ifelse(
    status == "red",
    "Escalate reactivation and stewardship review, reduce concentration dependence, and rebuild the evidence packet before the next campaign cycle.",
    ifelse(
      status == "yellow",
      "Increase cohort review cadence, tighten recency touchpoints, and validate upgrade messaging before the next appeal.",
      "Maintain current donor journey controls and preserve clean cohort evidence for fundraising leadership."
    )
  )

  lane_results <- data.frame(
    lane_id = scenario$lane_id,
    cohort = scenario$cohort,
    channel = scenario$channel,
    donors = scenario$donors,
    expected_retention_pct = scenario$expected_retention_pct,
    actual_retention_pct = scenario$actual_retention_pct,
    retention_delta_pct = retention_delta_pct,
    expected_upgrade_pct = scenario$expected_upgrade_pct,
    actual_upgrade_pct = scenario$actual_upgrade_pct,
    upgrade_delta_pct = upgrade_delta_pct,
    concentration_risk_pct = scenario$concentration_risk_pct,
    recency_gap_days = scenario$recency_gap_days,
    stewardship_gaps = scenario$stewardship_gaps,
    risk_score = risk_score,
    status = status,
    recommendation = recommendation,
    stringsAsFactors = FALSE
  )

  action_queue <- lane_results[, c("cohort", "channel", "risk_score", "recommendation")]
  action_queue <- action_queue[order(-action_queue$risk_score), ]

  list(
    scenario_title = "Donor cohort risk lab for retention drift, upgrade pressure, and stewardship gaps",
    generated_on = "2026-05-28",
    synthetic_data_notice = "Synthetic demonstration data only. This repo models fundraising cohort risk and does not contain real donor or nonprofit CRM records.",
    total_donors = sum(lane_results$donors),
    avg_retention_delta_pct = round(mean(lane_results$retention_delta_pct), 1),
    avg_upgrade_delta_pct = round(mean(lane_results$upgrade_delta_pct), 1),
    avg_recency_gap_days = round(mean(lane_results$recency_gap_days), 1),
    escalated_cohorts = sum(lane_results$status == "red"),
    lane_results = lane_results,
    action_queue = action_queue
  )
}

build_dashboard <- function() {
  analyze_donor_risk(sample_scenario())
}

base_css <- function() {
  paste0(
    ":root{--bg:#070a0f;--panel:#0b1220;--line:rgba(120,255,170,.18);--line2:rgba(120,255,170,.10);",
    "--text:#e9f3ff;--muted:rgba(233,243,255,.72);--muted2:rgba(233,243,255,.55);--bert:#37ff8b;--bert2:#19c7ff;",
    "--warn:#ffcc66;--bad:#ff5c7a;--plum:#b88cff;--shadow:0 18px 60px rgba(0,0,0,.55);",
    "--mono:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,'Courier New',monospace;",
    "--sans:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif}",
    "*{box-sizing:border-box}html,body{height:100%}body{margin:0;font-family:var(--sans);color:var(--text);",
    "background:radial-gradient(1200px 600px at 20% -10%, rgba(55,255,139,.18), transparent 60%),",
    "radial-gradient(900px 520px at 90% 0%, rgba(25,199,255,.16), transparent 55%),",
    "radial-gradient(1000px 600px at 50% 110%, rgba(55,255,139,.10), transparent 60%),",
    "linear-gradient(180deg,#05070c 0%,#070a0f 35%,#05070c 100%)}",
    ".grid-bg{position:fixed;inset:0;pointer-events:none;opacity:.12;z-index:-1;background-image:",
    "linear-gradient(to right, rgba(55,255,139,.14) 1px, transparent 1px),",
    "linear-gradient(to bottom, rgba(55,255,139,.10) 1px, transparent 1px);background-size:46px 46px;",
    "mask-image:radial-gradient(900px 600px at 40% 10%, #000 60%, transparent 100%)}",
    ".wrap{max-width:1280px;margin:0 auto;padding:24px 22px 80px}.topbar{display:flex;justify-content:space-between;",
    "align-items:flex-start;gap:14px;border-bottom:1px solid var(--line2);padding-bottom:14px;margin-bottom:22px;",
    "font-family:var(--mono);font-size:11px;letter-spacing:.16em;color:var(--muted);text-transform:uppercase}",
    ".topbar .left{color:var(--bert)}.topbar .right{text-align:right}.herorow{display:grid;grid-template-columns:1.45fr .85fr;gap:18px}",
    "@media (max-width:1000px){.herorow{grid-template-columns:1fr}}",
    ".hero,.panel,.mini,.tablewrap{background:linear-gradient(180deg, rgba(11,18,32,.95), rgba(8,14,26,.92));",
    "border:1px solid var(--line);border-radius:22px;box-shadow:var(--shadow)}.hero{padding:28px 28px 24px;border-top:2px solid var(--bert2)}",
    ".hero h1{font-size:60px;line-height:.97;margin:0 0 18px;font-weight:800;letter-spacing:-.5px}",
    "@media (max-width:700px){.hero h1{font-size:40px}}.hero p,.panel p,.mini p,.tablewrap p{color:var(--muted);font-size:15px;line-height:1.55}",
    ".chiprow{display:flex;flex-wrap:wrap;gap:8px}.meta-chip,.pill{font-family:var(--mono);font-size:11px;padding:7px 12px;border-radius:999px;",
    "border:1px solid var(--line);background:rgba(6,10,18,.4);color:var(--muted)}.side{display:flex;flex-direction:column;gap:14px}",
    ".mini{padding:18px}.mini .lbl,.section-note{font-family:var(--mono);font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:var(--bert2)}",
    ".mini h3{margin:8px 0 6px;font-size:28px;line-height:1.02}.section{margin-top:34px}.sh{display:flex;justify-content:space-between;align-items:baseline;gap:14px;",
    "padding-bottom:10px;border-bottom:1px solid var(--line2);margin-bottom:14px}.sh h2{margin:0;font-size:24px;font-weight:600}",
    ".sh .note{font-family:var(--mono);font-size:11px;color:var(--muted2);letter-spacing:.16em;text-transform:uppercase}",
    ".kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}@media (max-width:900px){.kpis{grid-template-columns:repeat(2,1fr)}}@media (max-width:640px){.kpis{grid-template-columns:1fr}}",
    ".kpi,.card{border:1px solid var(--line);border-radius:16px;padding:16px;background:linear-gradient(180deg, rgba(11,18,32,.85), rgba(8,14,26,.65))}",
    ".kpi .v{font-family:var(--mono);font-size:28px;font-weight:700}.kpi .lbl{font-family:var(--mono);font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:var(--muted);margin-top:6px}",
    ".kpi .h{font-size:12px;color:var(--muted);line-height:1.45;margin-top:8px}.green{color:var(--bert)}.cyan{color:var(--bert2)}.warn{color:var(--warn)}.plum{color:var(--plum)}.bad{color:var(--bad)}",
    ".cards{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}@media (max-width:1000px){.cards{grid-template-columns:1fr}}",
    ".card h3{margin:8px 0 8px;font-size:22px}.card .eyebrow{font-family:var(--mono);font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:var(--bert)}",
    "table{width:100%;border-collapse:collapse}th,td{padding:13px 14px;text-align:left;font-size:13.5px;vertical-align:top}",
    "thead th{font-family:var(--mono);font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted2);border-bottom:1px solid var(--line);background:rgba(11,18,32,.5)}",
    "tbody tr:hover{background:rgba(55,255,139,.03)}tbody td{color:var(--muted);border-bottom:1px solid var(--line2)}",
    ".tablewrap{padding:0;overflow:hidden}.status{display:inline-block;padding:4px 9px;border-radius:6px;border:1px solid currentColor;font-family:var(--mono);font-size:10px;letter-spacing:.1em;text-transform:uppercase}",
    ".quote{margin-top:34px;border:1px solid rgba(55,255,139,.22);background:radial-gradient(700px 200px at 0% 0%, rgba(55,255,139,.10), transparent 60%),linear-gradient(180deg, rgba(11,18,32,.92), rgba(8,14,26,.88));border-radius:18px;padding:24px 26px}",
    ".quote .lbl{font-family:var(--mono);font-size:11px;color:var(--bert);letter-spacing:.22em;text-transform:uppercase}.quote .q{margin-top:12px;font-size:32px;line-height:1.25;font-weight:600;max-width:1000px}",
    ".notice{margin-top:16px;padding:14px 16px;border:1px solid rgba(255,204,102,.28);border-left:4px solid var(--warn);border-radius:14px;background:rgba(255,204,102,.06);color:var(--muted)}",
    "footer{margin-top:30px;padding-top:14px;border-top:1px dashed var(--line2);display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap;font-family:var(--mono);font-size:11px;color:var(--muted2);letter-spacing:.08em}",
    "a{color:var(--bert2);text-decoration:none}"
  )
}

status_badge <- function(status) {
  accent <- ifelse(status == "green", "green", ifelse(status == "yellow", "warn", "bad"))
  sprintf("<span class=\"status %s\">%s</span>", accent, toupper(status))
}

row_html <- function(df) {
  pieces <- apply(df, 1, function(row) {
    sprintf(
      "<tr><td><b>%s</b><br><span class=\"section-note\">%s · %s</span></td><td>%s</td><td>%s pts</td><td>%s pts</td><td>%s days</td><td>%s</td></tr>",
      html_escape(row[["cohort"]]),
      html_escape(row[["lane_id"]]),
      html_escape(row[["channel"]]),
      html_escape(row[["donors"]]),
      html_escape(row[["retention_delta_pct"]]),
      html_escape(row[["upgrade_delta_pct"]]),
      html_escape(row[["recency_gap_days"]]),
      status_badge(row[["status"]])
    )
  })
  paste(pieces, collapse = "\n")
}

html_page <- function(title, description, content, canonical) {
  paste0(
    "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">",
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
    "<title>", html_escape(title), "</title>",
    "<meta name=\"description\" content=\"", html_escape(description), "\">",
    "<meta name=\"robots\" content=\"index,follow\">",
    "<meta property=\"og:title\" content=\"", html_escape(title), "\">",
    "<meta property=\"og:description\" content=\"", html_escape(description), "\">",
    "<meta property=\"og:type\" content=\"website\">",
    "<meta property=\"og:url\" content=\"", canonical, "\">",
    "<link rel=\"canonical\" href=\"", canonical, "\">",
    "<style>", base_css(), "</style></head><body><div class=\"grid-bg\"></div><div class=\"wrap\">",
    content,
    "</div></body></html>"
  )
}

overview_content <- function(result) {
  cards <- paste(mapply(function(lane_id, cohort, channel, donors, risk_score, status, recommendation) {
    sprintf("<div class=\"card\"><div class=\"eyebrow\">%s</div><h3>%s</h3><p>%s donors in the %s motion carry a cohort risk score of %s.</p><p>%s</p><p>%s</p></div>",
            html_escape(lane_id),
            html_escape(cohort),
            donors,
            html_escape(channel),
            html_escape(risk_score),
            status_badge(status),
            html_escape(recommendation))
  },
  result$lane_results$lane_id,
  result$lane_results$cohort,
  result$lane_results$channel,
  result$lane_results$donors,
  result$lane_results$risk_score,
  result$lane_results$status,
  result$lane_results$recommendation,
  USE.NAMES = FALSE), collapse = "")

  paste0(
    "<div class=\"topbar\"><div class=\"left\">language atlas · r nonprofit analytics surface</div>",
    "<div class=\"right\"><div>donors.kineticgain.com</div><div>generated ", html_escape(result$generated_on), " · nonprofit / foundation ops</div></div></div>",
    "<div class=\"herorow\"><section class=\"hero\">",
    "<div class=\"chiprow\"><span class=\"meta-chip\">R cohort analysis</span><span class=\"meta-chip\">retention drift</span><span class=\"meta-chip\">donor recency</span><span class=\"meta-chip\">appeal risk</span></div>",
    "<h1>Donor cohort risk lab for retention drift, upgrade pressure, and stewardship gaps.</h1>",
    "<p>A base-R operator surface for nonprofit and foundation teams: compare expected versus actual donor behavior, keep concentration and recency risks visible, and turn cohort drift into buyer-readable fundraising posture.</p>",
    "<div class=\"chiprow\"><span class=\"pill\">Route: /cohort-lane/</span><span class=\"pill\">Route: /retention-matrix/</span><span class=\"pill\">Route: /appeal-posture/</span></div>",
    "<div class=\"notice\">", html_escape(result$synthetic_data_notice), "</div>",
    "</section><aside class=\"side\">",
    sprintf("<div class=\"mini\"><div class=\"lbl\">Total donors</div><h3>%s</h3><p>Modeled donors included in the cohort-risk surface.</p></div>", result$total_donors),
    sprintf("<div class=\"mini\"><div class=\"lbl\">Average retention delta</div><h3>%s pts</h3><p>How far actual retention is drifting below expected cohort targets.</p></div>", result$avg_retention_delta_pct),
    sprintf("<div class=\"mini\"><div class=\"lbl\">Escalated cohorts</div><h3>%s</h3><p>Cohorts where fundraising posture now needs immediate action.</p></div>", result$escalated_cohorts),
    "</aside></div>",
    "<section class=\"section\"><div class=\"sh\"><h2>Control-plane summary</h2><div class=\"note\">Retention, upgrade, and recency from one R analysis path</div></div>",
    "<div class=\"kpis\">",
    sprintf("<div class=\"kpi\"><div class=\"v cyan\">%s pts</div><div class=\"lbl\">Retention Delta</div><div class=\"h\">Average gap between expected and actual cohort retention.</div></div>", result$avg_retention_delta_pct),
    sprintf("<div class=\"kpi\"><div class=\"v warn\">%s pts</div><div class=\"lbl\">Upgrade Delta</div><div class=\"h\">Average drift between expected and actual donor upgrades.</div></div>", result$avg_upgrade_delta_pct),
    sprintf("<div class=\"kpi\"><div class=\"v plum\">%s days</div><div class=\"lbl\">Recency Gap</div><div class=\"h\">Average number of days cohorts are lagging expected touchpoint cadence.</div></div>", result$avg_recency_gap_days),
    sprintf("<div class=\"kpi\"><div class=\"v bad\">%s</div><div class=\"lbl\">Escalated Cohorts</div><div class=\"h\">Cohorts requiring stewardship or appeal intervention.</div></div>", result$escalated_cohorts),
    "</div></section>",
    "<section class=\"section\"><div class=\"sh\"><h2>Cohort risk matrix</h2><div class=\"note\">Retention, upgrade, recency, and status</div></div>",
    "<div class=\"tablewrap\"><table><thead><tr><th>Cohort</th><th>Donors</th><th>Retention Delta</th><th>Upgrade Delta</th><th>Recency Gap</th><th>Status</th></tr></thead><tbody>",
    row_html(result$lane_results),
    "</tbody></table></div></section>",
    "<section class=\"section\"><div class=\"sh\"><h2>Review queue</h2><div class=\"note\">Modeled fundraising remediation sequence</div></div><div class=\"cards\">",
    cards,
    "</div></section>",
    "<div class=\"quote\"><div class=\"lbl\">Why this matters</div><div class=\"q\">A donor cohort risk lab becomes monetizable when the same R analysis can support campaign review packets, donor-health templates, and embedded fundraising evidence work.</div></div>",
    "<footer><div>discipline · donor cohort analytics</div><div>focus · retention / upgrades / recency / stewardship</div><div>overview snapshot</div><div><a href=\"https://github.com/mizcausevic-dev/\">GitHub</a> · <a href=\"https://www.linkedin.com/in/mirzacausevic/\">LinkedIn</a> · <a href=\"https://kineticgain.com/\">Kinetic Gain</a></div></footer>"
  )
}

cohort_lane_content <- function(result) {
  paste0(
    "<div class=\"topbar\"><div class=\"left\">donor cohort risk lab · cohort lane</div><div class=\"right\"><div>nonprofit / foundation ops</div><div>fundraising review board</div></div></div>",
    "<section class=\"hero\"><h1>Cohort drift stays tied to the fundraising motion that owns it.</h1><p>The cohort lane keeps expected versus actual retention, upgrade, recency, and stewardship gaps on one route so teams can review where donor health is softening before the next appeal cycle.</p><div class=\"notice\">", html_escape(result$synthetic_data_notice), "</div></section>",
    "<section class=\"section\"><div class=\"tablewrap\"><table><thead><tr><th>Cohort</th><th>Channel</th><th>Risk score</th><th>Stewardship gaps</th><th>Status</th></tr></thead><tbody>",
    paste(apply(result$lane_results, 1, function(row) {
      sprintf("<tr><td><b>%s</b><br><span class=\"section-note\">%s</span></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
              html_escape(row[["cohort"]]),
              html_escape(row[["lane_id"]]),
              html_escape(row[["channel"]]),
              html_escape(row[["risk_score"]]),
              html_escape(row[["stewardship_gaps"]]),
              status_badge(row[["status"]]))
    }), collapse = ""),
    "</tbody></table></div></section>"
  )
}

retention_matrix_content <- function(result) {
  lines <- paste(apply(result$lane_results, 1, function(row) {
    sprintf("<div class=\"card\"><div class=\"eyebrow\">%s</div><h3>%s</h3><p>Retention drift is %s points and upgrade drift is %s points for %s donors.</p><p>Recency gap is %s days against the expected cadence.</p><p>%s</p></div>",
            html_escape(row[["lane_id"]]),
            html_escape(row[["cohort"]]),
            html_escape(row[["retention_delta_pct"]]),
            html_escape(row[["upgrade_delta_pct"]]),
            html_escape(row[["donors"]]),
            html_escape(row[["recency_gap_days"]]),
            html_escape(row[["recommendation"]]))
  }), collapse = "")

  paste0(
    "<div class=\"topbar\"><div class=\"left\">donor cohort risk lab · retention matrix</div><div class=\"right\"><div>cohort drift by fundraising motion</div></div></div>",
    "<section class=\"hero\"><h1>Cohort drift stays readable for fundraising review.</h1><p>This route turns statistical movement into cohort-specific action cues teams can use for campaign planning, board packets, and stewardship cleanup before donor loss compounds.</p><div class=\"notice\">Synthetic demonstration data only. No real donor or CRM data is included.</div></section>",
    "<section class=\"section\"><div class=\"cards\">", lines, "</div></section>"
  )
}

appeal_posture_content <- function(result) {
  rows <- paste(apply(result$action_queue, 1, function(row) {
    sprintf("<tr><td><b>%s</b><br><span class=\"section-note\">%s</span></td><td>%s</td><td>%s</td></tr>",
            html_escape(row[["cohort"]]),
            html_escape(row[["channel"]]),
            html_escape(row[["risk_score"]]),
            html_escape(row[["recommendation"]]))
  }), collapse = "")

  paste0(
    "<div class=\"topbar\"><div class=\"left\">donor cohort risk lab · appeal posture</div><div class=\"right\"><div>review queue and fundraising evidence</div></div></div>",
    "<section class=\"hero\"><h1>Appeal and stewardship posture stay auditable.</h1><p>The posture route shows which cohorts need immediate reactivation or stewardship review and where fundraising evidence should tighten before leadership treats a soft quarter as noise.</p><div class=\"notice\">This is readiness and fundraising evidence posture only. It does not claim financial audit signoff or nonprofit compliance certification.</div></section>",
    "<section class=\"section\"><div class=\"tablewrap\"><table><thead><tr><th>Cohort</th><th>Risk score</th><th>Recommendation</th></tr></thead><tbody>", rows, "</tbody></table></div></section>"
  )
}

verification_content <- function(result) {
  paste0(
    "<div class=\"topbar\"><div class=\"left\">donor cohort risk lab · verification</div><div class=\"right\"><div>base R only</div></div></div>",
    "<section class=\"hero\"><h1>One analysis path, one static proof surface.</h1><p>The same base-R functions produce the cohort analysis, appeal posture, site pages, smoke checks, and README proof assets.</p><div class=\"notice\">", html_escape(result$synthetic_data_notice), "</div></section>",
    "<section class=\"section\"><div class=\"cards\">",
    "<div class=\"card\"><div class=\"eyebrow\">Validation</div><h3>R runtime</h3><p>Validated with Rscript demo, tests, site generation, and smoke checks.</p></div>",
    "<div class=\"card\"><div class=\"eyebrow\">Routes</div><h3>Static proof surface</h3><p>/ · /cohort-lane/ · /retention-matrix/ · /appeal-posture/ · /verification/ · /docs/</p></div>",
    "<div class=\"card\"><div class=\"eyebrow\">Commercial path</div><h3>Templates and consulting</h3><p>Template pack planned, with embedded fundraising cohort work by engagement.</p></div>",
    "</div></section>"
  )
}

docs_content <- function(result) {
  paste0(
    "<div class=\"topbar\"><div class=\"left\">donor cohort risk lab · docs</div><div class=\"right\"><div>kinetic gain embedded</div></div></div>",
    "<section class=\"hero\"><h1>Fundraising cohort proof for donor-health evidence operations.</h1><p>This repo sits in the Language Atlas and Industry Atlas at once: real R, Nonprofit / foundation operations framing, and a monetizable path into campaign review templates, donor-health briefs, and embedded fundraising evidence work.</p><div class=\"notice\">", html_escape(result$synthetic_data_notice), "</div></section>",
    "<section class=\"section\"><div class=\"cards\">",
    "<div class=\"card\"><div class=\"eyebrow\">Tier 1</div><h3>Public proof</h3><p>Open-source cohort-risk notebook and static dashboard routes with buyer-readable outputs.</p></div>",
    "<div class=\"card\"><div class=\"eyebrow\">Tier 2</div><h3>Template pack planned</h3><p>Donor cohort review packets, retention drift decks, and stewardship starter templates.</p></div>",
    "<div class=\"card\"><div class=\"eyebrow\">Tier 4</div><h3>Embedded by engagement</h3><p>Kinetic Gain can adapt the notebook for a nonprofit, foundation, or mission-driven fundraising team.</p></div>",
    "</div></section>"
  )
}

write_file <- function(path, text) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(text, path, useBytes = TRUE)
}

write_site <- function(result = build_dashboard()) {
  base <- "https://donors.kineticgain.com"
  dir.create("site", recursive = TRUE, showWarnings = FALSE)

  page_paths <- c(
    "index.html",
    file.path("cohort-lane", "index.html"),
    file.path("retention-matrix", "index.html"),
    file.path("appeal-posture", "index.html"),
    file.path("verification", "index.html"),
    file.path("docs", "index.html")
  )

  pages <- setNames(list(
    html_page("Donor cohort risk lab R", "Base-R nonprofit operator surface for retention drift, upgrade pressure, and stewardship gaps.", overview_content(result), base),
    html_page("Cohort lane · Donor cohort risk lab", "Fundraising cohort review and triage.", cohort_lane_content(result), paste0(base, "/cohort-lane/")),
    html_page("Retention matrix · Donor cohort risk lab", "Cohort drift and fundraising recommendations.", retention_matrix_content(result), paste0(base, "/retention-matrix/")),
    html_page("Appeal posture · Donor cohort risk lab", "Appeal and stewardship posture routing.", appeal_posture_content(result), paste0(base, "/appeal-posture/")),
    html_page("Verification · Donor cohort risk lab", "Validation and commercial path for the R donor-cohort surface.", verification_content(result), paste0(base, "/verification/")),
    html_page("Docs · Donor cohort risk lab", "Nonprofit / foundation-ops documentation and monetization path.", docs_content(result), paste0(base, "/docs/"))
  ), page_paths)

  for (relative in names(pages)) {
    write_file(file.path("site", relative), pages[[relative]])
  }

  write_file("site/robots.txt", paste(
    "User-agent: *",
    "Allow: /",
    paste0("Sitemap: ", base, "/sitemap.xml"),
    sep = "\n"
  ))

  sitemap <- paste0(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
    "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n",
    paste(
      sprintf("  <url><loc>%s%s</loc><lastmod>2026-05-28</lastmod></url>",
              base,
              c("", "/cohort-lane/", "/retention-matrix/", "/appeal-posture/", "/verification/", "/docs/")),
      collapse = "\n"
    ),
    "\n</urlset>\n"
  )
  write_file("site/sitemap.xml", sitemap)
  invisible(normalizePath("site", winslash = "/", mustWork = FALSE))
}
