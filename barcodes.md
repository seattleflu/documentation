# Barcodes

Barcodes for the study are generated as
[CualIDs](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5069752/) using
[ID3C's](https://github.com/seattleflu/id3c) `id3c identifier mint` command.

A good overview of the study's barcodes [exists
elsewhere](https://docs.google.com/document/d/1exaj_aGB8rqjMAwEznRYIR84J8486DyB3dNSAGnyHmM/edit).


## Making new barcodes

Each type of barcode used by the study is printed on different labels:

Different study arms use different colors and different numbers of copies of
each barcode, described by [this spreadsheet](https://docs.google.com/spreadsheets/d/1_UBOZ3pFq_oT-OIaFZfyvu9Qj9CpoZsRq4UjWkk37rE/edit#gid=0)
and summarized below:

Identifier set (type)               | SKU of labels     | Barcodes/box | Barcodes/sheet | Notes
----------------------------------- | ----------------- | -----------: | -------------: | -----
`samples`                           | [LCRY-2380][]     |          680 |             34 | in triplicate, with a column of blank labels for spacing
`collections-seattleflu.org`        | [LCRY-1100-Y][]   |        1,040 |             52 |
`collections-kiosks`                | [LCRY-1100-Y][]   |          520 |             26 | in duplicate
`collections-swab&send`             | [LCRY-1100-G][]   |          260 |             13 | in triplicate, with the last column blank
`collections-home-test`             | [LCRY-1100-G][]   |          260 |             13 | in triplicate, with the last column blank
`collections-household-observation` | [LCRY-1100-O][]   |          260 |             13 | in triplicate, with the last column blank
`collections-household-intervention`| [LCRY-1100-B][]   |          260 |             13 | in triplicate, with the last column blank
`collections-environmental`         | [LCRY-1100-R][]   |        1,040 |             52 |
`collections-fluathome.org`         | [LCRY-2380-Y][]   |        2,380 |            119 |
`kits-fluathome.org`                | [LCRY-1100-B][]   |        1,040 |             52 |
`test-strips-fluathome.org`         | [LCRY-2380-G][]   |        2,380 |            119 |

[LCRY-2380]: https://www.divbio.com/product/lcry-2380
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

The new identifiers and their associated barcodes will be stored in the ID3C
database for future reference.  A PDF of formatted barcode labels will be made
and saved to your computer.

Open up the new _barcode-labels.pdf_ file.  It should have 20 pages (of 52
barcodes each) formatted to print on a box of [LCRY-1100-Y][] sheets.

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
