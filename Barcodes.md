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


[labelmaker]: https://github.com/seattleflu/id3c/blob/master/lib/id3c/labelmaker.py


## Making new barcodes

Each type of barcode used by the study is printed on different labels:

Different study arms use different colors and different numbers of copies of
each barcode, described by [this spreadsheet](https://docs.google.com/spreadsheets/d/1_UBOZ3pFq_oT-OIaFZfyvu9Qj9CpoZsRq4UjWkk37rE/edit#gid=0)
and summarized below:

Identifier set (type)                             | SKU of labels     | Barcodes/box | Barcodes/sheet | Notes
------------------------------------------------- | ----------------- | -----------: | -------------: | -----
`samples`                                         | [LCRY-2380][]     |        1,020 |             51 | in duplicate, with the last column blank
`collections-seattleflu.org`                      | [LCRY-1100-Y][]   |        1,040 |             52 |
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
`collections-scan-kiosks`                         | [LCRY-1100][]     |        1,040 |             52 |SCAN STAVE-surge testing around vulnerable/exposures
`collections-clia-compliance`                     | [LCRY-1100][]     |        1,040 |             52 |CLIA barcodes (default layout)
`collections-clia-compliance`                     | [LCRY-2380][]     |        2,380 |             119|CLIA barcodes ('small' layout)
`kits-fluathome.org`                              | [LCRY-1100-B][]   |        1,040 |             52 |
`test-strips-fluathome.org`                       | [LCRY-2380-G][]   |        2,380 |            119 |
`samples-haarvi`                                  | [LCRY-2380][]     |        2,380 |            119 | small aliquoting barcodes for HAARVI
`collections-haarvi`                              | [LCRY-1100][]     |        1,040 |             52 |
`collections-household-general`                   | [LCRY-1100-O][]   |        1,040 |             52 | Season 3 household collection
`collections-uw-home`                             | [LCRY-1100-B][]   |          520 |             26 | in duplicate, Husky Coronavirus Testing mail (at-home)
`collections-uw-observed`                         | [LCRY-1100-B][]   |        1,040 |             52 | Husky Coronavirus Testing kiosk (in-person)
`collections-childcare`                           | [LCRY-1100][]   |          1,040 |             52 | singles, Childcare Study
`collections-school-testing-home`                 | [LCRY-1100][]   |            520 |             26 | duplicates, Snohomish Schools at home
`collections-school-testing-observed`             | [LCRY-1100][]   |            1040 |             52 | singles, Snohomish Schools observed/in-person
`collections-apple-respiratory`                   | [LCRY-1100][]   |            520 |             26 | duplicates, Apple Study
`collections-adult-family-home-outbreak`          | [LCRY-1100][]   |          1,040 |             52 | singlets, Adult Family Home (AFH) Outbreaks (not for Workplace Outbreaks)
`collections-workplace-outbreak`                  | [LCRY-1100][]   |          1,040 |             52 | singlets, Workplace Outbreaks (not for Adult Family Home AFH Outbreaks)



[LCRY-2380]: https://www.divbio.com/product/lcry-2380
[LCRY-1100]: https://www.divbio.com/product/lcry-1100
[LCRY-1100-Y]: https://www.divbio.com/product/lcry-1100-y
[LCRY-1100-G]: https://www.divbio.com/product/lcry-1100-g
[LCRY-1100-R]: https://www.divbio.com/product/lcry-1100-r
[LCRY-2380-Y]: https://www.divbio.com/product/lcry-2380-y
[LCRY-1100-B]: https://www.divbio.com/product/lcry-1100-b
[LCRY-1100-O]: https://www.divbio.com/product/lcry-1100-o
[LCRY-2380-G]: https://www.divbio.com/product/lcry-2380-g

These types exist as identifier sets within ID3C, which you can verify by
running:

    PGSERVICE=seattleflu-production \
      id3c identifier set ls

To generate, for example, one box of new Seattle Flu collection barcodes for
printing, run:

    PGSERVICE=seattleflu-production \
      id3c identifier mint collections-seattleflu.org 1040 --labels barcode-labels.pdf

An example value for 'labels': labels-2020-07-20-greek-matrix-samples.pdf

Assuming you're on a Linux machine, you can stream the barcode minting process with `tail -f /var/log/syslog`.

The new identifiers and their associated barcodes will be stored in the ID3C
database for future reference.  A PDF of formatted barcode labels will be made
and saved to your computer.

> Note: If you need to recreate labels for a previously generated set of
> barcodes, use the `id3c identifier labels` command.

Open up the new _barcode-labels.pdf_ file.  It should have 20 pages (of 52
barcodes each) formatted to print on a box of [LCRY-1100-Y][] sheets.

### Minting batches
We have a script on the backoffice server that is useful for generating batches of barcodes when the requester wants a 
maximum number of sheets in each PDF file. For example, if the requester asked for 40 sheets of CLIA barcodes in the small layout
in files of no more than 20 sheets each, the command would be:

PGSERVICE=seattleflu-production /opt/backoffice/bin/mint-barcodes-in-batch --identifier-set=collections-clia-compliance --per-sheet=26 --layout=small --max-sheets=20 --sheets=40 --prefix="/home/ubuntu/temp/" 

* --per-sheet: specifies how many barcodes fit on a sheet of labels
* --layout: specifies which label layout to print with. The default is 'default'.
* --max-sheets: specifies the maximum number of sheets per PDF file
* --sheets: specifies the number of sheets to be minted
* --prefix: specifics the text to pre-pend to the filename; this sets the path. We've found it useful to include the requester's name, 
e.g., --prefix="/home/ubuntu/temp/Evan_" 

Files will be named with this pattern: prefix_identifier_set_(the layout)_(number of sheets in the file)_sheets_(current date)_(the iteration number).pdf

For example: Peter_collections-uw-observed_default_15_sheets_2020-10-26_1.pdf

**

The Google Drive location where to put label PDFs is in the #barcodes channel topic in Slack.
Name the PDF file clearly and put it into the appropriate folder in the Google Drive.
The lab team will delete the PDF files from Google Drive when they have finished printing them. We don't delete the PDFs.

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
