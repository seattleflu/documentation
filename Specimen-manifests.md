Updating the [specimen manifests] ingest process requires two main steps:

1. Update the appropriate season config file for AWS and OneDrive in the [specimen manifests] repo with the new sheet metadata.

   e.g. If you're making changes for season 2, update `season-2-AWS-S3.yaml` and `season-2-OneDrive.yaml`.
This is the one we use to actually ingest the data into the ID3C database, adding them to sample.details.


2. If this is a new specimen manifest sheet, update [uw-retrospective-manifest.yml] in the [backoffice] repo, adding only the columns that are currently tracked in the other workbooks in this file.

   This is used to pull minimal info for UW retrospective samples that we then upload to REDCap.

Note: Our [manifest parsing script] currently does not have error handling for files that do not exist. So, please do not deploy to the backoffice until we have confirmation from the lab that they have uploaded the new workbook to AWS.

[specimen manifests]: https://github.com/seattleflu/specimen-manifests
[uw-retrospective-manifest.yml]: https://github.com/seattleflu/backoffice/blob/master/etc/uw-retrospectives-manifest.yaml
[backoffice]: https://github.com/seattleflu/backoffice
[manifest parsing script]: https://github.com/seattleflu/id3c/blob/master/lib/id3c/cli/command/manifest.py