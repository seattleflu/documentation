Documentation on the Seattle Coronavirus Assessment Network (SCAN) project

- [Return of results portal](#return-of-results-portal)
- [Adding a new study arm](#adding-a-new-study-arm)
- [Adding a new language](#adding-a-new-language)

## Return of results portal
Currently, we return SCAN participant's results via a dedicated page for SCAN at the [UW LabMed SecureLink portal]. (See the private [securelink GitHub repo].)

A SCAN participant must provide their collection barcode and date of birth in order to retrieve their results.

The following example data can be entered at the [SecureLink dev instance] to see a live view what a SCAN participant sees for each of the result codes:


| barcode | date of birth | result | pdf |
|---|---|---|---|
| AAAAAAAA | 2020-01-01 | not-received | no |
| BBBBBBBB | 2020-01-01 | pending      | no |
| CCCCCCCC | 2020-01-01 | never-tested | yes |
| DDDDDDDD | 2020-01-01 | negative     | yes |
| EEEEEEEE | 2020-01-01 | inconclusive | yes |
| FFFFFFFF | 2020-01-01 | positive     | yes |


Note that only the [SecureLink dev instance], not the live site, is compatible with these (fake) example data.
These example barcodes may one day reflect a real participant's collection barcode, therefore no test data are used on the live production site.


## Adding a new study arm

1. First, answer the questions listed in the [barcodes documentation] pertaining to creating new collections.
2. Create a new identifier set.
3. Create a new barcode label layout for the [labelmaker].
4. [Enable REDCap DETs] for the new project once testing is complete and it's ready for production.
5. Update the REDCap DET ETL with the new study's project ID and purview (see [example]).
   > Note: If the new REDCap project is _not_ identical to existing SCAN projects, this may required additional updates to the ETL.
6. Update the FHIR ETL with the new study's collection identifier set.
7. Add a new cronjob for the new REDCap DET ETL.
8. Decide if we need to manually generate DETs (for e.g. if the new study arm uses the REDCap mobile app or API for enrollments)
   > Note: we may not have to manually generate DETs if we receive at least one DET for an instrument containing a manually-updated field. If we have other required instruments, then that DET must come _after_ those instruments are complete. This works fairly well if the manually-updated field is in a later instrument, like kit unboxing.
9. Update the manifest ETL expected collection identifier sets
10. Update the SCAN RoR shipping view.
11. Update the reportable conditions shipping view with the new collection identifier set.
12. Update the backoffice export-redcap-scan script.
13. Update the [export-record-barcodes] script in the [scan-switchboard] repo with the new language's project ID and purview.
14. Update the [ID3C Glossary] with new definitions of how Encounters, Samples, Individuals (etc.) get created for this project.


## Adding a new language

Checklist
1. Insert `<span>` tags into the REDCap project fields while the project is still in development mode.
   - Download the existing data dictionary with the [download-data-dictionary] script.
   - Upload a modified data dictionary with injected HTML attributes via [upload-data-dictionary].
2. [Enable REDCap DETs] for the new project once testing is complete and it's ready for production.
3. Update the REDCap DET ETL with the new language's project ID and ISO code (see [example]).
4. Add a new cronjob for the new REDCap DET ETL.*
5. Create a new LaTeX PDF template in [lab-result-reports].
   Translations for the results PDFs live in a Google drive folder accessible via [this Trello card].
   - Rebuild the Docker image and push it to Docker Hub (see [README]).
   - Validate the newly generated PDFs with native speakers.
6. Update the SCAN RoR workflow in the [backoffice] repo:
   - Bump the Docker image version [generate-pdfs] uses.†
   - Add the new language ISO code to the `SCAN_LANGS` environment variable in [generate-pdfs].†
   - Add the new language to the `export-redcap-data()` function in [generate-results-csv].
7. Manually generate PDFs for all data on the S3 results file for the new language.†‡
8. Update securelink portal:
   - Add new "Next steps" translation and PDF button.†‡
     Translations are viewable via the Google drive link at [this Trello card].
   - Add new mock results PDFs for local development (e.g. CCCCCCCC-2020-01-01).†
   - Update the [get_pdf_report()] function in the python module to allow the new language code.
9. Update the [export-record-barcodes] script in the [scan-switchboard] repo with the new language's project ID and ISO code.

*: Depends on #3

†: Depends on #5

‡: Depends on #6


[barcodes documentation]: https://github.com/seattleflu/documentation/wiki/barcodes#creating-new-collections
[labelmaker]: https://github.com/seattleflu/id3c/blob/master/lib/id3c/labelmaker.py
[download-data-dictionary]: https://github.com/seattleflu/backoffice/blob/master/bin/redcap-data-dictionary/download-data-dictionary
[Enable REDCap DETs]: https://github.com/seattleflu/documentation/wiki/redcap#enable-dets-for-a-project
[upload-data-dictionary]: https://github.com/seattleflu/backoffice/blob/master/bin/redcap-data-dictionary/upload-data-dictionary
[example]: https://github.com/seattleflu/id3c-customizations/pull/99/commits/30fe06bc614f41c5fb44d83c5ec58a68a0b22dbd
[lab-result-reports]: https://github.com/seattleflu/lab-result-reports
[this Trello card]: https://trello.com/c/iaS57pKI
[README]: https://github.com/seattleflu/lab-result-reports/blob/master/README.md
[backoffice]: https://github.com/seattleflu/backoffice
[generate-pdfs]: https://github.com/seattleflu/backoffice/blob/master/bin/scan-return-of-results/generate-pdfs
[generate-results-csv]: https://github.com/seattleflu/backoffice/blob/master/bin/scan-return-of-results/generate-results-csv
[get_pdf_report()]: https://github.com/nkrumm/securelink/blob/d82a1871bcbaa7a90ea75b84a507e4cd6bcd8f30/app/__init__.py#L124
[export-record-barcodes]: https://github.com/seattleflu/scan-switchboard/blob/master/bin/export-record-barcodes
[scan-switchboard]: https://github.com/seattleflu/scan-switchboard
[UW LabMed SecureLink portal]: https://securelink.labmed.uw.edu/scan
[securelink GitHub repo]: https://github.com/nkrumm/securelink
[SecureLink dev instance]: https://securelink.labmed-dev.uw.edu/scan
[ID3C Glossary]: id3c-glossary
