- [REDCap projects](#redcap-projects)
  - [SCAN](#scan)
  - [SFS](#sfs)
- [FHIR](#fhir)

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
- [Kiosk]
  - `sfs_barcode` is not blank or `sfs_barcode_manual` is not blank

- [Swab & Send]
  - `return_utm_barcode` is not blank, or `pre_scan_barcode` is not blank, or `utm_tube_barcode_2` is not blank, or (`barcode_confirm` == "No" and `corrected_barcode` is not blank)

- [Asymptomatic Swab & Send]
  - `return_utm_barcode` is not blank, or `pre_scan_barcode` is not blank, or (`utm_tube_barcode` is not blank, or (`check_barcodes` == "No" and `corrected_barcode` is not blank)

- [Swab & Send + Home Flu]
  - `return_utm_barcode` is not blank, or `pre_scan_barcode` is not blank, or `utm_tube_barcode_2` is not blank, or `utm_tube_barcode_2_st` is not blank, or ((`barcode_confirm` or `barcode_confirm_st` == "No") and (`corrected_barcode` is not blank or `corrected_barcode_st` is not blank))


## FHIR
We represent an ID3C Sample in HL7 FHIR vocabulary as an [Specimen Resource].

[warehouse schema diagram]: https://github.com/seattleflu/documentation/blob/master/id3c-warehouse-schema.pdf
[SCAN ETL]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_scan.py
[Kiosk]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_kiosk.py
[Swab & Send]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_swab_n_send.py
[Asymptomatic Swab & Send]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_asymptomatic_swab_n_send.py
[Swab & Send + Home Flu]: https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_swab_and_home_flu.py
[Specimen Resource]: https://www.hl7.org/fhir/specimen.html
