# Exchanging self-test diagnostic results

This is an example FHIR R4 resource [Bundle][] for reporting the presence/absence
of influenza virus.  Using FHIR provides a well-documented structure and
semantics for representing this information, but for the actual exchange we
don't plan to implement the FHIR RESTful API.  Instead, bundle documents like
these will be POSTed to a custom API endpoint.

When creating each [Bundle][]:

  * Generate a new UUID v4 for the `id`.  This will help us identify specific
    bundles when troubleshooting.  Another kind of id can be used instead of
    UUIDs, as long as it's robustly unique and it can be used to link back to
    your original records.

  * Use the current ISO 8601 timestamp for `timestamp`.

For each [DiagnosticReport][] entry in the [Bundle][]:

  * Generate a new UUID v4 for the `id`.  This will help us identify specific
    reports (e.g. self-tests with your kit) when troubleshooting.

  * Use the ISO 8601 timestamp of when the self-test was performed for
    `effectiveDateTime`.

  * Use the actual specimen barcode scanned/input for the [Specimen][] reference's
    seattleflu.org identifier `value`.

  * Include a [resource reference][] for every individual observation in
    `result`.  These references refer to [contained resources][] in
    `contained`.

For each [Observation][] entry contained in the [DiagnosticReport][]:

  * Use the appropriate SNOMED CT _clinical finding_ concept or LOINC concept
    for `code`.  I've chosen two SNOMED CT concepts as examples which seem
    appropriate, but there are many options and others may be more precise.

  * Use the actual boolean test result for `valueBoolean`.  If three-valued
    logic is more appropriate (to include indeterminate results), this field
    can switch to `valueConceptCode`.

  * Use [Device][] reference as shown in example so that we can
  differentiate diagnostic results of different sources.

There is some room for structuring these results differently, particularly
around how the results are represented with SNOMED CT / LOINC codes.  The FHIR
spec contains [useful discussion and
guidance](http://www.hl7.org/implement/standards/fhir/observation.html#code-interop)
for different patterns of observation representation.

A [Bundle][] may contain more than one [DiagnosticReport][] if you wish you send
multiple results simultaneously.  Sending one at a time is also ok.

There is also room to include additional information about the participant,
their performance of the self-test, or the self-test kit/device itself via
included [Patient][] and [Encounter][].  I omitted these
as I'm not clear on what data might be useful or what you might want to
include.


[Bundle]: http://www.hl7.org/implement/standards/fhir/bundle.html
[DiagnosticReport]: http://www.hl7.org/implement/standards/fhir/diagnosticreport.html
[Observation]: http://www.hl7.org/implement/standards/fhir/observation.html
[Specimen]: http://www.hl7.org/implement/standards/fhir/specimen.html
[Patient]: http://www.hl7.org/implement/standards/fhir/patient.html
[Encounter]: http://www.hl7.org/implement/standards/fhir/encounter.html
[Device]: http://www.hl7.org/implement/standards/fhir/device.html
[resource reference]: http://www.hl7.org/implement/standards/fhir/references.html
[contained resources]: http://www.hl7.org/implement/standards/fhir/references.html#contained
