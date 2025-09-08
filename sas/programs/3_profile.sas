/* Basic data profiling */

title "Descriptor information for tsa.ClaimsImport";
proc contents data=tsa.ClaimsImport varnum;
run;

title "Descriptor information for tsa.claims_cleaned";
proc contents data=tsa.claims_cleaned varnum;
run;

title;

