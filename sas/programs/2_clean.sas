/* Clean and prepare data according to the case requirements */

/* Remove exact duplicate rows */
proc sort data=tsa.ClaimsImport out=tsa.Claims_NoDups noduprecs;
  by _all_;
run;

/* Sort by Incident_Date */
proc sort data=tsa.Claims_NoDups;
  by Incident_Date;
run;

/* Clean specified columns and create Date_Issues flag */
data tsa.claims_cleaned_raw;
  set tsa.Claims_NoDups;

  length Claim_Site Claim_Type Disposition $ 60;
  length Date_Issues $ 12;

  /* Replace missing with 'Unknown' */
  if missing(Claim_Site) then Claim_Site = 'Unknown';
  if missing(Claim_Type) then Claim_Type = 'Unknown';
  if missing(Disposition) then Disposition = 'Unknown';

  /* Fix Disposition typos and spacing */
  if strip(Disposition) = 'Closed: Canceled' then Disposition = 'Closed:Canceled';
  if strip(Disposition) = 'losed: Contractor Claim' then Disposition = 'Closed: Contractor Claim';

  /* Normalize Claim_Type categories */
  length _ct $ 200;
  _ct = upcase(coalescec(Claim_Type, ''));
  if index(_ct, 'PASSENGER PROPERTY LOSS') > 0 then Claim_Type = 'Passenger Property Loss';
  else if _ct = 'PASSENGER PROPERTY LOSS/INJURY' then Claim_Type = 'Passenger Property Loss';
  else if _ct = 'PASSENGER PROPERTY LOSS/INJUR' then Claim_Type = 'Passenger Property Loss';
  else if _ct = 'PROPERTY DAMAGE/PERSONAL INJURY' then Claim_Type = 'Property Damage';
  drop _ct;

  /* Normalize State and StateName to uppercase */
  if not missing(State) then State = upcase(State);
  if not missing(StateName) then StateName = upcase(StateName);

  /* Date Issues flag */
  Date_Issues = '';
  if missing(Incident_Date) or missing(Date_Received) then Date_Issues = 'Needs Review';
  else do;
    if year(Incident_Date) < 2002 or year(Incident_Date) > 2017
       or year(Date_Received) < 2002 or year(Date_Received) > 2017 then Date_Issues = 'Needs Review';
    else if Incident_Date > Date_Received then Date_Issues = 'Needs Review';
  end;

  /* Permanent formats */
  format Incident_Date Date_Received date9.;
  format Close_Amount dollar12.2;

  /* Labels */
  label Claim_Number  = 'Claim Number'
        Date_Received = 'Date Received'
        Incident_Date = 'Incident Date'
        Airport_Code  = 'Airport Code'
        Airport_Name  = 'Airport Name'
        Claim_Type    = 'Claim Type'
        Claim_Site    = 'Claim Site'
        Item_Category = 'Item Category'
        Close_Amount  = 'Close Amount'
        Disposition   = 'Disposition'
        StateName     = 'State Name'
        State         = 'State'
        County        = 'County'
        City          = 'City'
        Date_Issues   = 'Date Issues';

  /* Remove columns if present */
  drop Country City;
run;

/* Final sort ascending by Incident_Date */
proc sort data=tsa.claims_cleaned_raw out=tsa.claims_cleaned;
  by Incident_Date;
run;

