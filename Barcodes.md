Barcodes for the study are generated as
[CualIDs](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5069752/) using
[ID3C's](https://github.com/seattleflu/id3c) `id3c identifier mint` command.

A good overview of the study's barcodes [exists
elsewhere](https://docs.google.com/document/d/1exaj_aGB8rqjMAwEznRYIR84J8486DyB3dNSAGnyHmM/edit).


## Creating new collections

Before creating a new collection (typically for a new study arm), the following
questions should be answered:
   * What is the new collection name?
   * What do you want the collection barcode label to say?
   * How many replicates do you want? (e.g. singlet, duplicate, triplicate)

Once these concerns are addressed, use the `id3c identifier set` command to
create a new collection. Then, create a new label layout for the [labelmaker].
Now, you're ready to [mint barcodes](#making-new-barcodes)!
> Note: One-off requests for new collections do not necessarily need to have their label
settings merged to master or be tracked in the following barcode settings table. For example,
if an identifier set's layout normally prints two copies of each barcode, you can locally
edit the appropriate class in the labelmaker.py for the run.

Once the labelmaker is ready with the new layout, announce in the slack #barcodes channel that 
the barcodes for the new identifier set can be requested, and add the identifer set to the 
table below on this docs page. 


[labelmaker]: https://github.com/seattleflu/id3c/blob/master/lib/id3c/labelmaker.py


## Making new barcodes

Each type of barcode used by the study is printed on different labels:

Different study arms use different colors and different numbers of copies of
each barcode, described by [this spreadsheet](https://docs.google.com/spreadsheets/d/1_UBOZ3pFq_oT-OIaFZfyvu9Qj9CpoZsRq4UjWkk37rE/edit#gid=0)
and summarized below:

__Note__: The Barcodes/sheet reflects the number of unique barcodes per sheet according to the default copies per barcode of each collection set.
This number will change if you specify a different number of copies per barcode using the `--copies-per-barcode` option when minting or creating labels for barcodes.

Identifier set (type)                             | SKU of labels     | Barcodes/box | Barcodes/sheet | Notes
------------------------------------------------- | ----------------- | -----------: | -------------: | -----
`samples`                                         | [LCRY-2380][]     |        1,020 |             51 | in duplicate, with the last column blank
`collections-seattleflu.org`                      | [LCRY-1100-Y][]   |        1,040 |             52 | These are used for retrospective SCH samples
`collections-kiosks`                              | [LCRY-1100-Y][]   |          520 |             26 | in duplicate, one-off mint of singlets for shelters
`collections-kiosks-asymptomatic`                 | [LCRY-1100][]     |        1,040 |             52 |
`collections-swab&send`                           | [LCRY-1100-G][]   |          260 |             13 | in triplicate, with the last column blank
`collections-swab&send-asymptomatic`              | [LCRY-1100][]     |          520 |             26 | in duplicate
`collections-self-test`                           | [LCRY-1100-G][]   |          260 |             13 | in triplicate, with the last column blank
`collections-household-observation`               | [LCRY-1100-O][]   |          260 |             13 | in triplicate, with the last column blank, one-off mint of singlets for baseline swabs
`collections-household-observation-asymptomatic`  | [LCRY-1100-O][]   |        1,040 |             52 |
`collections-household-intervention`              | [LCRY-1100-B][]   |          260 |             13 | in triplicate, with the last column blank, one-off mint of singlets for baseline swabs
`collections-household-intervention-asymptomatic` | [LCRY-1100-B][]   |        1,040 |             52 |
`collections-environmental`                       | [LCRY-1100-R][]   |        1,040 |             52 |
`collections-fluathome.org`                       | [LCRY-2380-Y][]   |        2,380 |            119 |
`collections-scan`                                | [LCRY-1100][]     |          520 |             26 | in duplicate for now, might be triplicate if we start ROR
`collections-scan-kiosks`                         | [LCRY-1100][]     |        1,040 |             52 | SCAN STAVE-surge testing around vulnerable/exposures
`collections-scan-tiny-swabs`                     | [LCRY-2380][]     |        2,380 |            119 | singlets, TINY SCAN 
`collections-clia-compliance`                     | [LCRY-1100][]     |        1,040 |             52 | CLIA barcodes (default layout)
`collections-clia-compliance`                     | [LCRY-2380][]     |        2,380 |             119| CLIA barcodes ('small' layout)
`kits-fluathome.org`                              | [LCRY-1100-B][]   |        1,040 |             52 |
`test-strips-fluathome.org`                       | [LCRY-2380-G][]   |        2,380 |            119 |
`samples-haarvi`                                  | [LCRY-2380][]     |        2,380 |            119 | small aliquoting barcodes for HAARVI
`collections-haarvi`                              | [LCRY-1100][]     |        1,040 |             52 |
`collections-household-general`                   | [LCRY-1100-O][]   |        1,040 |             52 | Season 3 household collection
`collections-uw-home`                             | [LCRY-1100-B][]   |          520 |             26 | in duplicate, Husky Coronavirus Testing mail (at-home)
`collections-uw-observed`                         | [LCRY-1100-B][]   |        1,040 |             52 | Husky Coronavirus Testing kiosk (in-person)
`collections-uw-tiny-swabs`                       | [LCRY-2380][]     |        2,380 |            119 | singles, UW Tiny Swabs (pilot project)
`collections-uw-tiny-swabs-home`                  | [LCRY-2380][]     |        2,380 |            119 | singles, UW Tiny Swabs at home (unobserved)
`collections-uw-tiny-swabs-observed`              | [LCRY-2380][]     |        2,380 |            119 | singles, UW Tiny Swabs in-person (observed)
`collections-childcare`                           | [LCRY-1100][]   |          1,040 |             52 | **INACTIVE**, singles, Childcare Study
`collections-school-testing-home`                 | [LCRY-1100][]   |            520 |             26 | **INACTIVE**, duplicates, Snohomish Schools at home
`collections-school-testing-observed`             | [LCRY-1100][]   |           1040 |             52 | **INACTIVE**, singles, Snohomish Schools observed/in-person
`collections-apple-respiratory`                   | [LCRY-1100][]   |            520 |             26 | duplicates, Apple Study
`collections-apple-respiratory-serial`            | [LCRY-1100][]   |            520 |             26 | duplicates, the "serial" barcodes for Apple Study
`collections-adult-family-home-outbreak`          | [LCRY-1100][]   |          1,040 |             52 | singlets, Adult Family Home (AFH) Outbreaks (not for Workplace Outbreaks)
`collections-adult-family-home-outbreak-tiny-swabs`| [LCRY-2380][]  |          2,380 |            119 | singlets, TINY Adult Family Home (AFH) Outbreaks (not for Workplace Outbreaks)
`collections-workplace-outbreak`                  | [LCRY-1100][]   |          1,040 |             52 | singlets, Workplace Outbreaks (not for Adult Family Home AFH Outbreaks)
`collections-workplace-outbreak-tiny-swabs`       | [LCRY-2380][]   |          2,380 |            119 | singlets, TINY Workplace Outbreaks (not for Adult Family Home AFH Outbreaks)
`collections-radxup-yakima-schools-home`          | [LCRY-1100][]   |            520 |             26 | **INACTIVE**, duplicates, Yakima Schools (Radxup) at home
`collections-radxup-yakima-schools-observed`      | [LCRY-1100][]   |          1,040 |             52 | **INACTIVE**, singlets, Yakima Schools (Radxup) observed/in-person
`collections-airs'                                | [LCRY-1100-W][]  |            520 |             26 | duplicates, FH Prospective Sero Study AIM 3B (AIRS)


[LCRY-2380]: https://www.divbio.com/product/lcry-2380
[LCRY-1100]: https://www.divbio.com/product/lcry-1100
[LCRY-1100-Y]: https://www.divbio.com/product/lcry-1100-y
[LCRY-1100-G]: https://www.divbio.com/product/lcry-1100-g
[LCRY-1100-R]: https://www.divbio.com/product/lcry-1100-r
[LCRY-2380-Y]: https://www.divbio.com/product/lcry-2380-y
[LCRY-1100-B]: https://www.divbio.com/product/lcry-1100-b
[LCRY-1100-O]: https://www.divbio.com/product/lcry-1100-o
[LCRY-2380-G]: https://www.divbio.com/product/lcry-2380-g
[LCRY-1100-W]: https://www.divbio.com/product/lcry-1100

The filepaths in the following examples may need to be modified according to the location of the backoffice on your local system. It also requires a connection to an ID3C database.

These types exist as identifier sets within ID3C, which you can verify by
running:

    PGSERVICE=seattleflu-production \
      id3c identifier set ls

To generate, for example, one box of new Seattle Flu collection barcodes for
printing, run:

    cd ~/id3c
    
    PGSERVICE=seattleflu-production \
      pipenv run id3c identifier mint collections-seattleflu.org 1040 --labels barcode-labels.pdf

An example value for 'labels': Melissa_collections-seattleflu.org_default_20_sheets_2021-08-04_1.pdf,
where we find it useful to include requester's name, identifier set, layout, number of sheets, and date generated for file naming purposes.

Assuming you're on a Linux machine, you can stream the barcode minting process with `tail -f /var/log/syslog`.

The new identifiers and their associated barcodes will be stored in the ID3C
database for future reference.  A PDF of formatted barcode labels will be made
and saved to your computer.

Open up the new _barcode-labels.pdf_ file.  It should have 20 pages (of 52
barcodes each) formatted to print on a box of [LCRY-1100-Y][] sheets.

> Note: If you need to recreate labels for a previously generated set of
> barcodes, use the `id3c identifier labels` command. \
> For example: 
> ```
> PGSERVICE=seattleflu-production pipenv run id3c identifier labels _barcode-labels.pdf
> ```
> Modify the _barcode-labels filename at the end depending on what you want the output file to be called.
> 
> It will open up an interactive dialog and ask you which batch you want to reprint, and you’ll enter the index number of the batch you want to reprint.
> 
> Be mindful in what you select - do not want to reprint the same labels twice — duplicate barcode labels is no fun for us, the lab or participants. 

### Minting batches
We have a [script on the backoffice server](https://github.com/seattleflu/backoffice/blob/master/bin/mint-barcodes-in-batch) that is useful for generating batches of barcodes when the requester wants a 
maximum number of sheets in each PDF file. 

The filepaths in the following examples may need to be modified according to the location of the backoffice and directories on your local system.

For example, if the requester asked for 40 sheets of CLIA barcodes in the small layout
in files of no more than 20 sheets each, the command would be:

```
cd ~/id3c

PGSERVICE=seattleflu-production pipenv run /opt/backoffice/bin/mint-barcodes-in-batch \
  --identifier-set=collections-clia-compliance \ 
  --per-sheet=26 \
  --layout=small \
  --max-sheets=20 \
  --sheets=40 \
  --prefix="/home/ubuntu/temp/"
```

* `--identifier-set`: specifies which collection barcode to mint
* `--per-sheet`: specifies how many barcodes fit on a sheet of labels (refer to table above)
* `--layout`: specifies which label layout to print with. The default is 'default'.
* `--max-sheets`: specifies the maximum number of sheets per PDF file
* `--sheets`: specifies the number of sheets total to be minted
* `--prefix`: specifics the text to pre-pend to the filename; this sets the path. We've found it useful to include the requester's name, 
e.g., --prefix="/home/ubuntu/temp/Evan_" 

Files will be named with this pattern: prefix_identifier_set_(the layout)_(number of sheets in the file)_sheets_(current date)_(the iteration number).pdf

For example: Peter_collections-uw-observed_default_15_sheets_2020-10-26_1.pdf

### Uploading files to Google Drive
The Google Drive location where to put label PDFs is in the `#barcodes` channel topic in Slack.
Name the PDF file clearly and put it into the appropriate folder in the Google Drive.
The lab team will delete the PDF files from Google Drive when they have finished printing them. We don't delete the PDFs.

### Printing files
When printing there a couple tips for higher-quality output:

1. Change the paper type to labels in your computer's print dialog.

2. Make sure the sheets are oriented correctly in the paper tray.  The
   pre-printed number on each sheet marks the intended bottom left corner of
   the page.

3. Use the secondary or auxiliary paper tray on your printer if possible to
   avoid other people's print jobs interrupting yours.

Labels include a reference (e.g. `seattleflu.org`) so that there is a
point-of-contact to gain more context about what's in a tube.  Otherwise, the
only information would be an opaque id.  This is important for the future
longevity of samples when someone unrelated to the current project may be
responsible for their care.
