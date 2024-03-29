- [REDCap projects](#redcap-projects)
  - [SCAN](#scan)
  - [SFS](#sfs)
- [FHIR](#fhir)
- [Identifying Sample Origin or Project](#identifying-sample-origin-or-project)
  - [Collection Barcode](#collection-barcode)
  - [Lab AQ Sheet](#lab-aq-sheet)
  - [Site from Encounter metadata](#site-from-encounter-metadata)

A `sample` in ID3C is "[A sample collected from an individual during a specific encounter](https://github.com/seattleflu/id3c/blob/c5ee5b8d9dbd87a89213f5044a1632cecefd4e7f/schema/deploy/warehouse/sample.sql#L23)."
See the [warehouse schema diagram] to visualize how samples are related to encounters and other concepts in ID3C.

## REDCap projects
We wait to create Samples in ID3C until the following conditions are met for each project:

### SCAN
[SCAN ETL]

- Mail
  - `post_collection_data_entry_qc` is complete and verified
  - `return_utm_barcode` is not blank

- In-person (kiosk)
  - `nasal_swab_collection` is complete and verified
  - `utm_tube_barcode_2` is not blank or `reenter_barcode` == `reenter_barcode_2`

- Husky Testing (kiosk)
  - `nasal_swab_collection` is complete and verified
  - `utm_tube_barcode_2` is not blank or `reenter_barcode` == `reenter_barcode_2`

### SFS
- [Childcare]
  - `post_collection_data_entry_qc` is complete and verified
  - One of the following barcode fields is not blank:
    - `return_utm_barcode`
    - `utm_tube_barcode`
    - `pre_scan_barcode`

- [UW Reopening]
  - the sample is a swab-n-send sample and `post_collection_data_entry_qc` is complete and verified or the sample is a kiosk sample and `kiosk_registration_4c7f` is complete and verified
  - `collect_barcode_kiosk` is not blank or `return_utm_barcode` is not blank or `pre_scan_barcode` is not blank

- [Kiosk]
  - `sfs_barcode` is not blank or `sfs_barcode_manual` is not blank

- [Swab & Send]
  - `return_utm_barcode` is not blank, or `pre_scan_barcode` is not blank, or `utm_tube_barcode_2` is not blank, or (`barcode_confirm` == "No" and `corrected_barcode` is not blank)

- [Asymptomatic Swab & Send]
  - `return_utm_barcode` is not blank, or `pre_scan_barcode` is not blank, or (`utm_tube_barcode` is not blank, or (`check_barcodes` == "No" and `corrected_barcode` is not blank)

- [Swab & Send + Home Flu]
  - `return_utm_barcode` is not blank, or `pre_scan_barcode` is not blank, or `utm_tube_barcode_2` is not blank, or `utm_tube_barcode_2_st` is not blank, or ((`barcode_confirm` or `barcode_confirm_st` == "No") and (`corrected_barcode` is not blank or `corrected_barcode_st` is not blank))


## FHIR
We represent an ID3C Sample in HL7 FHIR vocabulary as a [Specimen Resource].


## Identifying Sample Origin or Project
### Collection Barcode
* Year1 - all collection barcodes were in the same identifier set
* Year2 and on - Collection barcodes are assigned to specific collection identifier set that matches to projects/sub-projects
* UW retrospectives do not have collection barcodes
* Should be the ultimate source of truth of a sample's origin/project

### Lab AQ Sheet
* sample_origin - matches to big projects
* swab_site - matches to specific sites within projects
* currently a dropdown box in Excel sheet
* ingested as free text into ID3C without any verification
* used as backup for identifying sample's origin

### Site from Encounter metadata
* sites linked to encounter when ingesting participant metadata
* specific site of collection, there may be multiple sites per project
* site is missing for samples that do not have encounter data ingested


[warehouse schema diagram]: https://github.com/seattleflu/documentation/blob/master/id3c-warehouse-schema.pdf
[SCAN ETL]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_scan.py
[Kiosk]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_kiosk.py
[Swab & Send]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_swab_n_send.py
[Asymptomatic Swab & Send]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_asymptomatic_swab_n_send.py
[Swab & Send + Home Flu]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_swab_and_home_flu.py
[Specimen Resource]: https://www.hl7.org/fhir/specimen.html
[UW Reopening]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_uw_reopening.py
[Childcare]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_childcare.py
