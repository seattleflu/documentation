Updating the [specimen manifests] ingest process requires two main steps:

1. Update the appropriate season config file for AWS and OneDrive in the [specimen manifests] repo with the new sheet metadata.

   e.g. If you're making changes for season 2, update `season-2-AWS-S3.yaml` and `season-2-OneDrive.yaml`.

2. If this is a new specimen manifest sheet, update [uw-retrospective-manifest.yml] in the [backoffice] repo, adding only the columns that are currently tracked in the other workbooks in this file.


[specimen manifests]: https://github.com/seattleflu/specimen-manifests
[uw-retrospective-manifest.yml]: https://github.com/seattleflu/backoffice/blob/master/etc/uw-retrospectives-manifest.yaml
[backoffice]: https://github.com/seattleflu/backoffice
