- [REDCap projects](#redcap-projects)
  - [SCAN](#scan)
  - [SFS](#sfs)
- [FHIR](#fhir)

An `encounter` in ID3C is "[An interaction with an individual to collect point-in-time information or samples](https://github.com/seattleflu/id3c/blob/c5ee5b8d9dbd87a89213f5044a1632cecefd4e7f/schema/deploy/warehouse/encounter.sql#L25)."
An associated [Individual] and Site are required to create an Encounter (see [warehouse schema diagram]).

## REDCap projects
We create Encounters from a REDCap record (commonly called a study "enrollment").
Sometimes, a single REDCap record maps to multiple Encounters in ID3C.
For example, intitial and follow-up surveys are treated as separate Encounters with the same [Individual].
In addition to requiring sufficient information to create an associated [Individual] and Site (i.e. physical place of encounter), we wait to create Encounters in ID3C until the following conditions are met for each project:

### SCAN
[SCAN ETL]
- Mail
  - `consent_form` is complete and verified
  - `enrollment_questionnaire` is complete and verified
  - `illness_q_date` is not blank or `back_end_mail_scans` is complete and verified
  - `enrollment_date` is not blank

  > Note: while not required to create an encounter, `post_collection_data_entry_qc` must be complete and verified to link an associated [Sample].

- In-person (kiosk)
  - `consent_form` is complete and verified
  - `illness_questionnaire` is complete and verified
  - `consent_date` is not blank
  > Note: while not required to create an encounter, `nasal_swab_collection` must be complete and verified to link an associated [Sample].

- Husky Test (kiosk)
  - `consent_form` is complete and verified
  - `enrollment_questionnaire` is complete and verified
  - `consent_date` and `location_type` fields are not blank
  > Note: while not required to create an encounter, `nasal_swab_collection` must be complete and verified to link an associated [Sample].

### SFS
- [Kiosk]
  - `screening` is complete and verified
  - `main_consent_form` is complete and verified
  - `enrollment_questionnaire` is complete and verified
  - `language_questions` != 'Spanish'
  - we can create an associated [Sample]
  - `enrollment_date` is not blank

- [Swab & Send]
  - `consent` is complete and verified
  - `enrollment_questionnaire` is complete and verified
  - `back_end_mail_scans` is complete and verified
  - `illness_questionnaire_nasal_swab_collection` is complete and verified
  - `post_collection_data_entry_qc` is complete and verified
  - we can create an associated [Sample]
  - `enrollment_date_time` is not blank

- [Asymptomatic Swab & Send]
  - `consent_form` is complete and verified
  - `shipping_information` is complete and verified
  - `back_end_mail_scans` is complete and verified
  - `day_0_enrollment_questionnaire` is complete and verified
  - `post_collection_data_entry_qc` is complete and verified
  - we can create an associated [Sample]
  - `enrollment_date` is not blank

- [Swab & Send + Home Flu]
  - `screening` is complete and verified
  - `consent` is complete and verified
  - `back_end_mail_scans` is complete and verified
  - `illness_questionnaire` is complete and verified
  - `post_collection_data_entry_qc` is complete and verified
  - we can create an associated [Sample]
  - `enrollment_date` is not blank

## FHIR
We represent an ID3C Encounter in HL7 FHIR vocabulary as an [Encounter Resource].

[Individual]: individuals
[warehouse schema diagram]: https://github.com/seattleflu/documentation/blob/master/id3c-warehouse-schema.pdf
[Sample]: samples
[SCAN ETL]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_scan.py
[Kiosk]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_kiosk.py
[Swab & Send]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_swab_n_send.py
[Asymptomatic Swab & Send]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_asymptomatic_swab_n_send.py
[Swab & Send + Home Flu]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_swab_and_home_flu.py
[Encounter Resource]: https://www.hl7.org/fhir/encounter.html
