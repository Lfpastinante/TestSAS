/* PDF report generation (excludes rows with date issues) */

ods noproctitle;
ods pdf file="&report_pdf." style=journal;

/* 1) How many date issues globally */
title "Global Data Issues (Date_Issues = 'Needs Review')";
proc sql noprint;
  select count(*) into :num_date_issues trimmed
  from tsa.claims_cleaned
  where Date_Issues = 'Needs Review';
quit;

proc sql;
  select "Date issues (global)" as Metric length=30, "&num_date_issues" as Value length=12;
quit;

/* 2) Claims by year (global, excluding date issues) */
title "Claims by Incident Year (Global, excluding date issues)";
data work._claims_year;
  set tsa.claims_cleaned;
  if missing(Date_Issues);
  Incident_Year = year(Incident_Date);
run;

proc freq data=work._claims_year nlevels;
  tables Incident_Year / nocum;
run;

proc sgplot data=work._claims_year;
  vbar Incident_Year;
  yaxis label="Number of Claims";
  xaxis integer values=(2002 to 2017);
run;

/* Dynamic state selection */
%let state_code = %upcase(&state_code);
title "State Summary: &state_code (excluding date issues)";

/* 3) Frequencies for Claim_Type, Claim_Site, Disposition for selected state */
proc freq data=tsa.claims_cleaned(where=(missing(Date_Issues) and upcase(State)="&state_code"));
  tables Claim_Type Claim_Site Disposition / nocum;
run;

/* 4) Summary stats for Close_Amount for selected state */
proc means data=tsa.claims_cleaned(where=(missing(Date_Issues) and upcase(State)="&state_code")) mean min max sum maxdec=0;
  var Close_Amount;
run;

ods pdf close;
title;

