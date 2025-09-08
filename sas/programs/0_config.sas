/* SAS Project Configuration */

options validvarname=v7 mprint mlogic symbolgen;

%let project_root = /workspace/sas;
%let csv_path = /workspace/Workshop/Data/TSAClaims2002_2017.csv;
%let out_root = &project_root./output;
%let lib_path = &project_root./tsa_lib;
%let report_pdf = &out_root./ClaimReports_Nombre_Apellido1_Apellido2.pdf;

/* Dynamic state selection for reporting */
%let state_code = NY;

libname tsa "&lib_path.";

filename reportpdf "&report_pdf.";

