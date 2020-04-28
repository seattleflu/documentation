# SCAN

Documentation on the Seattle Coronavirus Assessment Network (SCAN) project

## Adding a new language

Checklist
1. Insert `<span>` tags into the REDCap project fields.
   - Download the existing data dictionary with the [download-data-dictionary] script.
   - Upload a modified data dictionary with injected HTML attributes via [upload-data-dictionary].
2. Enable REDCap DETs for the new project.
3. Update the REDCap DET ETL with the new language's project ID and ISO code (see [example]).
4. Add a new cronjob for the new REDCap DET ETL.
5. Create a new LaTeX PDF template in [lab-result-reports].
   Translations for the results PDFs live in a Google drive folder accessible via [this Trello card].
   - Rebuild the Docker image and push it to Docker Hub (see [README]).
6. Update the SCAN RoR workflow in the [backoffice] repo:
   - Bump the Docker image version [generate-pdfs] uses.*
   - Add the new language ISO code to the `for` loop in [generate-pdfs].*
   - Add the new language to the `export-redcap-data()` function in [generate-results-csv].
7. Manually generate PDFs for all data on the S3 results file for the new language.* **
8. Update securelink portal:
   - Add new "Next steps" translation and PDF button.* **
     Translations are viewable via the Google drive link at [this Trello card].
   - Add new mock results PDFs for local development (e.g. CCCCCCCC-2020-01-01). *
   - Update the [get_pdf_report()] function in the python module to allow the new language code.

*: Depends on #5

**: Depends on #6


[download-data-dictionary]: https://github.com/seattleflu/backoffice/blob/master/bin/redcap-data-dictionary/download-data-dictionary
[upload-data-dictionary]: https://github.com/seattleflu/backoffice/blob/master/bin/redcap-data-dictionary/upload-data-dictionary
[example]: https://github.com/seattleflu/id3c-customizations/pull/99/commits/30fe06bc614f41c5fb44d83c5ec58a68a0b22dbd
[lab-result-reports]: https://github.com/seattleflu/lab-result-reports
[this Trello card]: https://trello.com/c/iaS57pKI
[README]: https://github.com/seattleflu/lab-result-reports/blob/master/README.md
[backoffice]: https://github.com/seattleflu/backoffice
[generate-pdfs]: https://github.com/seattleflu/backoffice/blob/master/bin/scan-return-of-results/generate-pdfs
[generate-results-csv]: https://github.com/seattleflu/backoffice/blob/master/bin/scan-return-of-results/generate-results-csv
[get_pdf_report()]: https://github.com/nkrumm/securelink/blob/d82a1871bcbaa7a90ea75b84a507e4cd6bcd8f30/app/__init__.py#L124
