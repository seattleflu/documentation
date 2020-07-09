[FHIR](https://www.hl7.org/fhir/) is a standard for health care data exchange.
It is our intended standard for enrollment data, selected for its interoperability and clear specifications.
Here is a [brief intro to FHIR](http://www.hl7.org/implement/standards/fhir/overview-dev.html).


## REDCap

Our goal with FHIR is to take a REDCap record from any project and transform it into a FHIR bundle as JSON.


## FHIR Resources

A [Resource](http://www.hl7.org/implement/standards/fhir/resource.html) is an entity that contains a set of structured data items described by the resource type definition.
They can be represented in [mutiple formats](http://www.hl7.org/implement/standards/fhir/formats.html), including JSON.

See Level 3 and Level 4 of the stack in the [FHIR R4 specs](http://www.hl7.org/implement/standards/fhir/modules.html) for information pertaining to FHIR Resources.


## FHIR Bundles

A [Bundle](http://www.hl7.org/implement/standards/fhir/bundle.html) is a collection of Resources with context.
Bundles are useful for returning a set of Resources matching a criteria or grouping a self-contained set of Resources to form a Document.

We plan to use a Bundle of type "collection" for REDCap records.
A suitable alternative to a collection Bundle would be the [Document format](http://www.hl7.org/implement/standards/fhir/documents.html), which is a Bundle of type "document" that includes some other requirements and formalities we likely don't need.

The resources contained in the collection would at a minimum need to include a [Specimen](http://www.hl7.org/implement/standards/fhir/specimen.html) (including our barcode as an identifier) and one or more [Observations](http://www.hl7.org/implement/standards/fhir/observation.html).
Additional information you might send about the participant or their encounter with your app could be included as a [Patient](http://www.hl7.org/implement/standards/fhir/patient.html) and/or [Encounter](http://www.hl7.org/implement/standards/fhir/encounter.html) record.

> Note that the "collection Bundle" means a set of things, not a collected specimen.
>
> A collection Bundle would contain:
> * 1+ Specimen(s) (including barcode)
> * 1+ Observation(s)
> * 1 Patient and/or 1+ Encounter(s)
