An `individual` in ID3C is "[A single, real person (or other member of a population)](https://github.com/seattleflu/id3c/blob/c5ee5b8d9dbd87a89213f5044a1632cecefd4e7f/schema/deploy/warehouse/individual.sql#L17)."
A unique Individual identifier is required to create an Individual in ID3C.
Individuals are required when creating an associated [Encounter] (see [warehouse schema diagram]).

## REDCap projects
We [created unique, individual identifier strings](https://github.com/seattleflu/id3c-customizations/blob/bdb64db700da9667a8908b425d1a3236e8f5f806/lib/seattleflu/id3c/cli/command/etl/fhir.py#L461) using PII from a participant that we then pass through a [SHA 256 hash function](https://github.com/seattleflu/id3c-customizations/blob/bdb64db700da9667a8908b425d1a3236e8f5f806/lib/seattleflu/id3c/cli/command/clinical.py#L158).
The identifier string for an individual is created by joining their:
* [canonicalized name](https://github.com/seattleflu/id3c-customizations/blob/bdb64db700da9667a8908b425d1a3236e8f5f806/lib/seattleflu/id3c/cli/command/etl/fhir.py#L497)
* sex
* birthdate
* zipcode

### UW Re-opening
* For UW re-opening projects, the most stable identifier to match participants is the UW NetID.
* We hash the stripped and lowercase `netid` field to create the individual identifier.


If any piece of the information listed above is missing, then we create an individual identifier by hashing the REDCap URL, project ID, and record ID.


> Note: When creating a unique identifier, there are very important considerations when hashing, such as normalization of each data point going into the hash, how missing data is handled, and how a secret is incorporated to prevent PII-leakage.

## FHIR
We represent an ID3C Individual in HL7 FHIR vocabulary as a [Patient Resource].

[warehouse schema diagram]: https://github.com/seattleflu/documentation/blob/master/id3c-warehouse-schema.pdf
[Encounter]: encounters
[Patient Resource]: https://www.hl7.org/fhir/patient.html
