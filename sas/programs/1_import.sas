/* Import TSAClaims2002_2017.csv into permanent library tsa as ClaimsImport */

options validvarname=v7;

proc import datafile="&csv_path." out=tsa.ClaimsImport dbms=csv replace;
  guessingrows=max;
  getnames=yes;
  datarow=2;
run;

/* Preview first rows to confirm import */
title "Preview of tsa.ClaimsImport (first 20 rows)";
proc print data=tsa.ClaimsImport(obs=20);
run;
title;

