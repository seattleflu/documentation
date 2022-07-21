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
    - [Scan Encounters with Best Available Vaccination Data v1](#scan-encounters-with-best-available-vaccination-data-v1)
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
