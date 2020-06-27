# Survey data dictionary and flow chart

Kiosk- and clinic-based collection sites in the 2018—19 season used a mobile
app called ["FluTrack"](https://github.com/auderenow/learn/tree/master/FluTrack)
developed by [Audere](https://auderenow.org) to collect consent and
survey questionnaire information.

The different questionnaires are embedded in the app's source code as data
structures.  This documentation repository contains programs for extracting the
data dictionary for reference and external use, such as making a [flow
chart](survey-flow.pdf).

## Updating

You'll need a checkout of <https://github.com/auderenow/learn> in
`../audere/learn` to do this the first time.

    pushd ../audere/learn
    git pull
    cd FluTrack/
    yarn install
    yarn add ts-node    # required by our program
    popd

    make -B

If Audere makes substantial code changes or adds new questionnaire features,
our program may require updating to account for it.
