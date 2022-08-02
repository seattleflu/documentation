# Data Dictionary for ID3C Tables
Below is a data dictionary for data stored in ID3C. Data is organized by its location within the ID3C schema. Relational linkages
have been preserved where possible.

## Database Directory
- [Warehouse](#warehouse)
    - [Encounter](#encounter)
    - [Individual](#individual)
    - [Sample](#sample)
    - [Presence Absence](#presence-absence)
    - [Organism](#organism)
    - [Target](#target)
    - [Location](#location)
    - [Site](#site)
    - [Encounter Location](#encounter-location)
    - [Encounter Location Relation](#encounter-location-relation)
    - [Identifier](#identifier)
    - [Identifier Set](#identifier-set)
    - [Identifier Set Use](#identifier-set-use)
    - [Sequence Read Set](#sequence-read-set)
    - [Consensus Genomce](#consensus-genome)
    - [Genomic Sequence](#genomic-sequence)
    - [Kit](#kit)
- [Receiving](#receiving)
    - [Clinical](#clinical)
    - [Consensus Genome](#consensus-genome-1)
    - [Longitudinal](#longitudinal)
    - [Enrollment](#enrollment)
    - [FHIR](#fhir)
    - [Manifest](#manifest)
    - [Presence Absence](#presence-absence-1)
    - [REDCap DET](#redcap-det)
    - [Sequence Read Set](#sequence-read-set-1)
- [Shipping](#shipping)
    - [HCov19 Presence Absence Result v1](#hcov19-presence-absence-result-v1)
    - [Genome Submission Metadata v1](#genome-submission-metadata-v1)
    - [Sample with Best Available Encounter Data v1](#sample-with-best-available-encounter-data-v1)
    - [Incidence Model Observation v4](#incidence-model-observation-v4)
    - [Observation With Presence Absence Result V3](#observation-with-presence-absence-result-v3)
    - [FHIR Encounter Details V2](#fhir-encounter-details-v2)
    - [SCAN Enrollments V1](#scan-enrollments-v1)
    - [SCAN Encounters with Best Available Vaccination Data v1](#scan-encounters-with-best-available-vaccination-data-v1)
    - [SCAN Encounters V1](#scan-encounters-v1)
    - [UW Reopening Encounters V1](#uw-reopening-encounters-v1)
    - [UW Reopening Enrollment FHIR Encounter Details V1](#uw-reopening-enrollment-fhir-encounter-details-v1)
- [Operations](#operations)
    - [Deliverables Log](#deliverables-log)
    - [Test Quota](#test-quota)

## Warehouse
The warehouse schema is where raw data from projects ingested into ID3C lives. The data in this schema is standardized and analysis ready.

### Encounter
Rows in the `encounter` table represent: An interaction with an individual to collect point-in-time information or samples

#### Encounter Columns
- `encounter_id`: Internal id of this encounter; integer
- `identifier`: External identifier for this encounter; case-sensitive; text
- `individual_id`: Internal id of the [individual](#individual) who was encountered; integer
- `site_id`: Internal id of the [site](#site) where the encounter occurred; integer
- `encountered`: When the encounter occurred; timestamp
- `details`: Additional information about this encounter which does not have a place in the relational schema; jsonb
- `age`: Age of individual at the time of this encounter; interval
- `created`: When this encounter record was first processed by ID3C; timestamp
- `modified`: When this encounter record was last modified; timestamp

### Individual
Rows in the `individual` table represent: A single, real person (or other member of a population)

#### Individual Columns
- `individual_id`: Internal id of this individual; integer
- `identifier`: External identifier for this individual (e.g. study participant id); text
- `sex`: Sex assigned at birth; assigned-sex (see fhir documentation [here](<http://www.hl7.org/implement/standards/fhir/codesystem-administrative-gender.html>))
- `details`: Additional information about this individual which does not have a place in the relational schema; jsonb
- `created`: When this individual record was first processed by ID3C; timestamp
- `modified`: When this individual record was last modified; timestamp

### Sample
Rows in the `sample` table represent: A sample collected from an individual during a specific encounter

#### Sample Columns
- `sample_id`: Internal id of this sample; integer
- `identifier`: A unique external [identifier](#identifier) assigned to this sample; text
- `encounter_id`: The [encounter](#encounter) where the sample was collected; integer
- `details`: Additional information about this sample which does not have a place in the relational schema; jsonb
- `collection_identifier`: A unique external [identifier](#identifier) assigned to the collection of this sample; text
- `collected`: The date when this sample was collected; date
- `created`: When this sample was first processed by ID3C; timestamp
- `modified`: When this sample was last modified; timestamp

### Presence Absence
Rows in the `presence_absence` table represent: A presence/absence test result from an individual sample

#### Presence Absence Columns
- `presence_absence_id`: Internal id of this presence/absence test; integer
- `identifer`: External id of this presence/absence test; integer
- `sample_id`: Internal id of the [sample](#sample) that is being tested for presence/absence of a target; integer
- `target_id`: Internal id of the [target](#target) for the presence/absence test; integer
- `present`: The result of a presence/absence test. True if the target is found, False if not, null if inconclusive; boolean
- `details`: The details for each replicate of a presence/absence test; integer
- `created`: When this presence/absence test was first processed by ID3C; timestamp
- `modified`: When this presence/absence test was last modified; timestamp

### Organism
Rows in the `organism` table represent: Hierarchical classification of taxa

#### Organism Columns
- `organism_id`: Internal id of this organism; used only for internal foreign keys; integer
- `lineage`: Label tree of ancestors with this organism as the leaf/final label; ltree
- `identifiers`: Key-value pairs of external identifiers (i.e. dbxrefs) for this organism; keys should use well-known database or ontology prefix (e.g. NCBITaxon); hstore
- `details`: Additional information about this organism which does not have a place in the relational schema

### Target
Rows in the `target` table represent: A thing (e.g. pathogen) that can be detected in presence-absence testing

#### Target Columns
- `target_id`: Internal id of this target; integer
- `identifier`: An identifier assigned to this target by the testing center, assumed to be stable and unique; text
- `control`: Whether the this target is a control. True if it is, False if not; boolean
- `organism_id`: Internal id of the [organism](#organism) detected by this target; most-specific available; integer

### Location
Rows in the `location` table represent: Hierarchical geospatial locations. Note these locations use EPSG:4326, a latitude/longitude coordinate system used by traditional GPS services

#### Location Columns
- `location_id`: Internal id of this location; integer
- `identifier`: External identifier by which this location is known; citext
- `scale`: Relative size or extent of this location (e.g. country, state, city); citext
- `hierarchy`: Set of key-value pairs describing where this location fits within a hierarchy; hstore
- `point`: Representative point geometry in WGS84 (EPSG:4326); geometry(Point,4326)
- `polygon`: Multi-polygon geometry in WGS84 (EPSG:4326); geometry(MultiPolygon,4326)
- `simplified_polygon`: Multi-polygon geometry in WGS84 (EPSG:4326) with reduced complexity/accuracy, intended for cartographic use; geometry(MultiPolygon,4326)
- `details`: Additional information about this location which does not have a place in the relational schema; jsonb
- `created`: When this location was first processed by ID3C; timestamp
- `modified`: When this location was last modified; timestamp

### Site
Rows in the `site` table represent: A real-world or virtual/logical location where individuals are encountered

#### Site Columns
- `site_id`: Internal id of this site; integer
- `identifier`: External identifier for this site; case-preserving but must be unique case-insensitively; text
- `details`: Additional information about this site which does not have a place in the relational schema; jsonb

### Encounter Location
Rows in the `encounter_location` table represent: The association between an encounter and location

#### Encounter Location Columns
- `encounter_id`: Internal id of the [encounter](#encounter); integer
- `location_id`: Internal id of the [location](#location); integer
- `relation`: The [relation](#encounter-location-relation) between the encounter and location, e.g. collection site, residence, workplace, etc; citext
- `details`: Additional information about this encounter-location which does not have a place in the relational schema; jsonb
- `created`: When this encounter/location relation was first processed by ID3C; timestamp
- `modified`: When this encounter/location relation was last modified; timestamp

### Encounter Location Relation
Rows in the `encounter_location_relation` table represent: Controlled vocabulary for encounter/location relationships

#### Encounter Location Relation Columns
- `relation`: A relation between an encounter and location, e.g. collection site, residence, workplace, etc; citext
- `priority`: Arbitrary inter-relation ranking, where smaller numbers mean greater importance within this ID3C instance.  Used to determine the default "primary" location related to an encounter when there is more than one; integer

### Identifier Set
Rows in the `identifier_set` table represent: A conceptual group of identifiers used for a common purpose

#### Identifer Set Columns
- `identifier_set_id`: Internal id of this identifier set; integer
- `name`: The well-known, unique name of the set (e.g. `collections-scan`, `collections-airs`, etc.); text
- `description`: A plain text description of the purpose and usage of this set; text
- `use`: A standard identifier use type, e.g. sample, collection, clia; citext

### Identifier
Rows in the `identifier` table represent: Globally unique ids and their CualID barcodes, used for tracking physical things

#### Identifier Columns
- `uuid`: UUIDv4 that should be used in programmatic and downstream data processing; relates to both the `identifier` and `collection-identifier` of [sample](#sample) records; uuid
- `barcode`: Short suffix of UUID (CualID) used as a tracking barcode; citext
- `identifier_set_id`: Internal id of the [identifier set](#identifer-set) this identifier belongs to; integer
- `generated`: When this identifier was generated; timestamp

### Identifier Set Use
Rows in the `identifier_set_use` table represent: Controlled vocabularly defining how an identifier set is used

#### Identifier Set Use Columns
- `use`: A standard identifier use type, e.g. sample, collection, clia; citext
- `description`: A plain text description of this identifier use type; text

### Sequence Read Set
Rows in the `sequence_read_set` table represent: A set of references to sequence reads from an individual sample

#### Sequence Read Set Columns
- `sequence_read_set_id`: Internal id of this set of sequence reads; integer
- `sample_id`: Internal id of the [sample](#sample) from which the sequence reads were generated; integer
- `urls`: External object store urls that hold the sequence reads; text[]
- `details`: Additional information about this sequence read set which does not have a place in the relational schema; jsonb
- `created`: When this sequence read set was first processed by ID3C; timestamp
- `modified`: When this sequence read set was last modified; timestamp

### Consensus Genome
Rows in the `consensus_genome` table represent: A whole consensus genome for an organism extracted from a sample that may have been generated from a sequence read set

#### Consensus Genome Columns
- `consensus_genome_id`: Internal id of this consensus genome; integer
- `sample_id`: Internal id of the [sample](#sample) from which this consensus genome was extracted; integer
- `organism_id`: Internal id of the [organism](#organism) to which this consensus genome belongs to; integer
- `sequence_read_set_id`: Internal id of the [sequence read set](#sequence-read-set) that was used to generate this consensus genome; may be null if the genome was generated from an
external source; integer
- `details`: Additional information about this consensus genome which does not have a place in the relational schema; jsonb

### Genomic Sequence
Rows in the `genomic_sequence` table represent: A genomic sequence from a genome. There may be multiple sequences per genome if the genome is segmented (e.g. Influenza genomes)

#### Genomice Sequence Columns
- `genomic_sequence_id`: Internal id of this genomic sequence; integer
- `identifier`: An external, unqiue identifier for this genomic sequence; text
- `segment`: The segment of the genome that this genomic sequence represents; citext
- `seq`: A succession of letters indicating the order of nucleotides of the genomic sequence; text
- `consensus_genome_id`: Internal id of the [consensus genome](#consensus-genome) that this genomic sequence belongs to; integer
- `details`: Additional information about this genomic sequence which does not have a place in the relational schema; jsonb
- `created`: When this genomic sequence was first processed by ID3C; timestamp
- `modified`: When this genomic sequence was last modified; timestamp

### Kit
Rows in the `kit` table represent: A self-test kit connected to an encounter and 2 different samples

#### Kit Columns
- `kit_id`: Internal id of this kit; integer
- `identifier`: A unique exteranl identifier assigned to this kit; text
- `encounter_id`: Internal id of the [encounter](#encounter) to which this kit is associated; integer
- `rdt_sample_id`: Internal id of the [sample](#sample) collected from the residual RDT extractant; integer
- `utm_sample_id`: Internal id of the [sample](#sample) collected from the second swap; integer
- `details`: Additional information about this kit which does not have a place in the relational schema; jsonb

## Receiving
The receiving table stores non-relational (or minimally-relational) data before it is transformed and loaded into the warehouse
by one of our ETL processes

### Clinical
Rows in the `clinical` table represent: A set of clinical documents; append only

#### Clinical Columns
- `clinical_id`: Internal id of this clinical record set; integer
- `document`: JSON document created from a pre-processed Excel file; json
- `received`: When this clinical document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

### Consensus Genome
Rows in the `consensus_genome` table represent: A set of consensus genome documents; append only

#### Consensus Genome Columns
- `consensus_genome_id`: Internal id of this consensus genome; integer
- `document`: Original consensus genome JSON document; json
- `received`: When this consensus genome document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

### Enrollment
Rows in the `enrollment` table represent: A set of enrollment documents; append only

#### Enrollment Columns
- `enrollment_id`: Internal id of this enrollment document; integer
- `document`: Original enrollment JSON document; json
- `received`: When this enrollment document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

### FHIR
Rows in the `fhir` table represent: A set of [FHIR](fhir) documents; append only

#### FHIR Columns
- `fhir_ud`: Internal id of this fhir record set; integer
- `document`: JSON document in [FHIR format](http://www.hl7.org/implement/standards/fhir/formats.html); json
- `received`: When this FHIR document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

### Longitudinal
Rows in the `longitudinal` table represent: A set of longitudianl documents; append only

#### Longitudinal Columns
- `longitudinal_id`: Internal id of this longitudinal document; integer
- `document`: JSON document created from a pre-processed Excel file; json
- `received`: When this longitudinal document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

### Manifest
Rows in the `manifest` table represent: A set of manifest records; append only

#### Manifest Columns
- `manifest_id`: Internal id of this manifest document; integer
- `document`: Manifest record as a JSON document; json
- `received`: When this manifest document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

### Presence Absence
Rows in the `presence_absence` table represent: A set of presence/absence documents; append only

#### Presence Absence Columns
- `presence_absence_id`: Internal id of this presence/absence document; integer
- `document`: Original presence/absence JSON document; json
- `received`: When this presence/absence document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

### REDCap DET
Rows in the `redcap_det` table represent: A set of REDCap DET request data documents; append only

#### REDCap DET Columns
- `redcap_det_id`: Internal id of this REDCap DET document; integer
- `document`: JSON document created from REDCap DET request data; json
- `received`: When this REDCap DET document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

### Sequence Read Set
Rows in the `sequence_read_set` table represent: A set of references to sequence reads; append only

#### Sequence Read Set Columns
- `sequence_read_set_id`: Internal id of this sequence read set document; integer
- `document`: Original sequence read set JSON document; json
- `received`: When this sequence read set document was received; timestamp
- `processing_log`: Event log recording details of ETL into data warehouse; jsonb

## Shipping
Outgoing warehouse data prepared for external consumers

### FHIR Questionnaire Responses V1
`fhir_questionnaire_responses_v1` is a view of FHIR Questionnaire Responses stored in an [encounter's](#encounter) details

#### FHIR Questionnaire Responses V1 Columns
- `encounter_id`: Internal id of the [encounter](#encounter) this response is linked with; integer
- `link_id`: Identifier of the question this response relates to; text
- `string_response`: If the response to the question is a string, it is present in this field; text[]
- `boolean_response`: If the response to the question is a boolean, it is present in this field; boolean
- `date_response`: If the response to the question is a date, it is present in this field; text[]
- `integer_response`: If the response to the question is an integer, it is present in this field; integer[]
- `numeric_response`: If the response to the question is numeric, it is present in this field; numeric[]
- `code_response`: If the response to this question is encoded, it is present in this field; text[]

### Genome Submission Metadata V1
`genome_submission_metadata_v1` is a view of minimal metadata used for consensus genome submissions

#### Genome Submission Metadata V1 Columns
- `sfs_sample_identifier`: A unique external [identifier](#identifier) assigned to this [sample](#sample); text
- `sfs_sample_barcode`: Short suffix of UUID (CualID) used as a tracking barcode, relates to the sample [identifier](#identifier); citext
- `sfs_collection_barcode`: Short suffix of UUID (CualID) used as a tracking barcode, relates to the collection [identifier](#identifier); citext
- `collection_date`: The date on which this sample was collected; timestamp
- `swab_type`: The type of swab used to collect the sample (e.g. `ans`, `mtp`, `np`); text
- `source`: The study group for which this sample belongs to (e.g. `SCH`, `SFS`, `AIRS`, etc.); text
- `puma`: The puma code associated with the collection of this sample; text
- `county`: The county to which the census tract associated with the collection of this sample; text
- `state`: The state associated with the collection of this sample; text
- `baseline_surveillance`: Whether or not this sample can be considered baseline surveillance; This includes samples that were randomly sampled for genomic surveillance, not identified in a targeted sampling effort, and/or sampled across targeted efforts in order to better represent a community; For more details see descriptions [here](https://www.aphl.org/programs/preparedness/Crisis-Management/Documents/Technical-Assistance-for-Categorizing-Baseline-Surveillance-Update-Oct2021.pdf); boolean

### HCOV19 Presence Absence Result V1
`hcov19_presence_absence_result_v1` is a view of hCov-19 Samples with Non-Clinical Presence / Absence Results

#### HCOV19 Presence Absence Result V1 Columns
- `presence_absence_id`: Internal id of the [presence / absence](#presence-absence) result this result is linked with; integer
- `result_ts`: The timestamp associated with when this result was released. Note that this is the internal samplify timestamp (in PST) when the result was released if it is after 2022-07-18, the internal samplify timestamp (in GMT) if it is after 2022-06-09 (but before 2022-07-18), or the last modified date of the record if it is before 2022-06-09; timestamp
- `hcov19_result_release_date`: The timestamp when this record was created; timestamp
- `target`: Internal id of the [target](#target) for the presence/absence test; integer
- `organism`: Internal id of the [organism](#organism) detected by this target; most-specific available; integer

### Incidence Model Observation V4
`incidence_model_observation_v4` is a view of warehoused samples and important questionnaire responses for modeling and visualization

#### Incidence Model Observation V4 Columns
- `encounter`: External identifier for this [encounter](#encounter); case-sensitive; text
- `encountered_week`: The week during which this encounter occurred; text
- `site`: External identifier for the [site](#site) at which this encounter occurred; text
- `site_type`: Classification of the role of a [site](#site) (e.g. retrospective, clinical); text
- `individual`: External identifier for this [individual](#individual) (e.g. study participant id); text
- `sex`: Sex assigned at birth; assigned-sex (see fhir documentation [here](<http://www.hl7.org/implement/standards/fhir/codesystem-administrative-gender.html>))
- `age_bin_fine`: Five year range into which an individual's age at encounter falls; intervalrange
- `age_range_fine_lower`: Lower bound of the above five year range; inclusive; numeric
- `age_range_fine_upper`: Upper bound of the above five year range; exclusive; numeric
- `age_range_coarse`: Coarse age range into which an individual's age at encounter falls; intervalrange
- `age_range_coarse_lower`: Lower bound of the above coarse age range; inclusive; numeric
- `age_range_coarse_upper`: Upper bound of the above coarse age range; exclusive; numeric
- `address_identifier`:  External identifier by which this residence [location](#location) is known; citext
- `residence_census_tract`: Census tract containing this residence in the [location](#location) hierearchy; text
- `residence_puma`: Puma code associated with this residence in the [location](#location) hierarchy; text
- `flu_shot`: Whether or not this individual had received a flu shot when encountered; boolean
- `symptoms`: Symptoms experienced by the individual at the time of encounter; text array
- `manifest_origin`: The origin of the sample (e.g. `hmc_retro`, `sch_retro`); text
- `swab_type`: The type of swab used to collect the sample (e.g. `ans`, `mtp`, `np`); text
- `collection_matrix`: The collection matrix method for this sample (e.g. `dry`, `utm_vtm`); text
- `sample`: A unique external [identifier](#identifier) assigned to this [sample](#sample); text

### Observation With Presence Absence Result V3
`observation_with_presence_absence_result_v3` is a view joining the `incidence_model_observation_v4`, the `presence_absence_result_v2`, and the `hcov19_observation_v1` views.

#### Observation With Presence Absence Result V3 Columns
- `target`: Internal id of the [target](#target) for the presence/absence observation; integer
- `organism`: Internal id of the [organism](#organism) detected by this target; most-specific available; integer
- `present`: The result of a presence/absence test. True if the target is found, False if not, null if inconclusive; boolean
- `presence`: The result of a presence/absence test. 1 if the target is found, 0 if not, null if inconclusive; integer
- `device`: The device this presence/absence test was run on (e.g. `TaqmanQPCR`, `OpenArray`); text
- `assay_type`: The category of the assay for this test (e.g. `Clia`, `Research`); text
- all other columns are defined above in the documentation for `incidence_model_observation_v4`.

### Sample With Best Available Encounter Data V1
`sample_with_best_available_encounter_data_v1` is a view of warehoused samples combined with best available envounter date and site details.

#### Sample With Best Available Encounter Data V1 Columns
- `sample_id`: Internal id of this [sample](#sample); integer
- `has_encounter_data`: Whether or not this sample has associated encounter data; boolean
- `best_available_encounter_date`: The date on which the best available encounter occurred; date
- `season`: Season during which this encounter occurred; Y1 is prior to October 1st 2019, Y2 prior to November 1st 2020, Y3 prior to November 1st 2021, and Y4 prior to November 1st 2022; text
- `best_available_site_id`: Internal identifier for the [site](#site) where this encounter took place; integer
- `best_available_site`: External identifier for the [site](#site) where this encounter took place; text
- `best_available_site_type`: Classification of the role of a [site](#site) (e.g. `retrospective`, `clinical`) where this encounter took place; text
- `best_available_site_category`: Classification of the category of a [site](#site) (e.g. `community`, `hospital`) where this encounter took place; text

### FHIR Encounter Details V2
`fhir_encounter_details_v2` is a view of SCAN encounter data in the FHIR format.

#### FHIR Encounter Details V2 Columns
For additional details about columns in this view, check out the REDCap codebook for the project [at this location](https://redcap.iths.org/redcap_v12.3.3/Design/data_dictionary_codebook.php?pid=22461). The full column list is excluded here due to its length.

### SCAN Enrollments V1
`scan_enrollments_v1` is a view of enrollment data from the SCAN project.

#### SCAN Enrollments V1 Columns
- `illness_questionnaire_date`: The date on which the illness questionnaire for this enrollment was completed; text
- `scan_study_arm`: The study arm under which this enrollment occurred; text
- `priority_code`: The priority code, if it exists, used by the participant when creating this enrollment; text
- `puma`: The puma code for the location associated with this enrollment record; text
- `neighborhood_district`: The neighborhood associated with this location (e.g. `ballard`, `downtown`, `lake_union`); text
- `geo_location_name`: The area name based off the Puma location associated with this enrollment. See [descriptions](https://www2.census.gov/geo/pdfs/reference/puma/2010_PUMA_Names.pdf); text
- `kit_received`: Whether or not a kit was sent along with the enrollment for this participant; boolean

### SCAN Encounters With Best Available Vaccination Data V1
`scan_encounters_with_best_available_vaccination_data_v1` is a view of SCAN encounters with best available vaccination data transformation applied

#### SCAN Encounters With Best Available Vaccination Data V1 Columns
- `individual`: External identifier for this [individual](#individual) (e.g. study participant id); text
- `encounter_id`: Internal id of this [encounter](#encounter); integer
- `encountered`: Date on which this [encounter](#encounter) occurred; date
- `pt_entered_covid_vax`: Whether or not an individual reported covid vaccine information for this encounter; text
- `pt_entered_covid_doses`: The number of doses of a covid vaccine an individual reported having had for this encounter; text
- `calculated_covid_doses`: The number of doses it was calculated an individual had at this encounter; text
- `calculated_vac_date_1`: The calculated date at which an individual got their first dose of the vaccine (most common first dose date); text
- `calculated_vac_name_1`: The calculated vaccine name of an individual's first dose (most common name); text
- `calculated_vac_date_2`:The calculated date at which an individual got their second dose of the vaccine (most common second dose date); text
- `calculated_vac_name_2`: The calculated vaccine name of an individual's second dose (most common name); text
- `calculated_vac_date_3`: The calculated date at which an individual got their third dose of the vaccine (most common third dose date); text
- `calculated_vac_name_3`: The calculated vaccine name of an individual's third dose (most common name); text
- `vac_date_1_out_of_range`: Whether the first dose date is out of order given the other calculated dates; This can nullify or alter the calculated `best_available_vac_status` for an individual; integer
- `vac_date_2_out_of_range`: Whether the second dose date is out of order given the other calculated dates; This can nullify or alter the calculated `best_available_vac_status` for an individual; integer
- `vac_date_3_out_of_range`: Whether the third dose date is out of order given the other calculated dates; This can nullify or alter the calculated `best_available_vac_status` for an individual; integer
- `best_available_vac_status`: The best available vaccination status for an individual given the calculations above; possible values are `not_vaccinated`, `boosted`, `fully_vaccinated`, `invalid`, `partially_vaccindated`, `unknown`; text

### SCAN Encounters V1
`scan_encounters_v1` is a view of encounter data from the SCAN project. Note that duplicate encounters in this view may exist if an encounter encompasses multiple tests. This can happen in rare occasions when 2 kits are sent out for an encounter and registered in REDCap, with one kit on the incident report and not-tested and one kit tested.

#### SCAN Encounters V1 Columns
For additional details about columns in this view, check out the REDCap codebook for the project [at this location](https://redcap.iths.org/redcap_v12.3.3/Design/data_dictionary_codebook.php?pid=22461). The full column list is excluded here due to its length.

### UW Reopening Encounters V1
`uw_reopening_encounters_v1` is a view of encounter data tied to enrollment questionnaire data for HCT encounters.

#### UW Reopening Encounters V1 Columns
For additional details about columns in this view, check out the REDCap codebook for the project [at this location](https://hct.redcap.rit.uw.edu/redcap_v12.3.3/Design/data_dictionary_codebook.php?pid=148). The full column list is excluded here due to its length.

### UW Reopening Enrollment FHIR Encounter Details V1
`uw_reopening_enrollment_fhir_encounter_details_v1` is a view of enrollment details in the FHIR format.

#### UW Reopening Enrollment FHIR Encounter Details V1 Columns
For additional details about the columns in this view, check out the REDCap codebook for the project [at this location](https://hct.redcap.rit.uw.edu/redcap_v12.3.3/Design/data_dictionary_codebook.php?pid=148). The full column list is excluded here due to its length.

## Operations

### Deliverables Log
Rows in the `deliverables_log` table represent: Deliverables sent by either our Linelist or Return of Results jobs

#### Deliverables Log Columns
- `deliverables_log_id`: Internal id of this deliverable; integer
- `sample_barcode`: The [sample](#sample) barcode associated with this deliverable; citext
- `collection_barcode`: The collection barcode associated with this deliverable; citext
- `details`: Additional information about this deliverable which does not have a place in the relational schema; jsonb
- `process_name`: The process which sent this deliverable; text
- `sent`: When this deliverable was sent; timestamp

### Test Quota
Rows in the `test_quota` table represent: Quota entries for HCT testing invites

#### Test Quota Columns
- `name`: Name of the process using this quota; text
- `timespan`: Timespan during which this quota is active; timestamp range
- `max`: The maximum number of testing entries alloted to this entry timespan; integer
- `used`: The number of testing entries currently used during this entry timespan; integer
