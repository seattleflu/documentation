-- This script requires that "\set individual ..." has been run first.

begin;

create temporary table to_delete on commit drop as
    select distinct
        individual_id,
        encounter_id,
        sample.sample_id,
        presence_absence_id,
        sequence_read_set.sequence_read_set_id,
        consensus_genome.consensus_genome_id,
        genomic_sequence_id,
        sample.identifier as sample_identifier

    from warehouse.individual
    left join warehouse.encounter using (individual_id)
    left join warehouse.sample using (encounter_id)
    left join warehouse.presence_absence using (sample_id)
    left join warehouse.sequence_read_set on sample.sample_id = sequence_read_set.sample_id
    left join warehouse.consensus_genome on sample.sample_id = consensus_genome.sample_id
    left join warehouse.genomic_sequence using (consensus_genome_id)

    where individual.identifier = :'individual'
;

create temporary table sample_barcodes on commit drop as
    select barcode
    from warehouse.identifier
    where uuid::text in (
        select identifier from warehouse.sample join to_delete using (sample_id)
        union
        select collection_identifier from warehouse.sample join to_delete using (sample_id)
    )
;

create temporary table fhir_docs on commit drop as
    select fhir_id
    from receiving.fhir,
         json_array_elements(document -> 'entry') as entries,
         json_array_elements(entries -> 'resource' -> 'identifier') as identifiers
    where identifiers::jsonb @> jsonb_build_object('system', 'https://seattleflu.org/individual', 'value', :'individual')
;

\echo
\echo '# warehouse.genomic_sequence'
delete from warehouse.genomic_sequence where genomic_sequence_id in (select genomic_sequence_id from to_delete);

\echo
\echo '# warehouse.consensus_genome'
delete from warehouse.consensus_genome where consensus_genome_id in (select consensus_genome_id from to_delete);

\echo
\echo '# warehouse.seqeunce_read_set'
delete from warehouse.sequence_read_set where sequence_read_set_id in (select sequence_read_set_id from to_delete);

\echo
\echo '# warehouse.presence_absence'
delete from warehouse.presence_absence where presence_absence_id in (select presence_absence_id from to_delete);

\echo
\echo '# warehouse.sample'
delete from warehouse.sample where sample_id in (select sample_id from to_delete);

\echo
\echo '# warehouse.encounter_location'
delete from warehouse.encounter_location where encounter_id in (select encounter_id from to_delete);

\echo
\echo '# warehouse.encounter'
delete from warehouse.encounter where encounter_id in (select encounter_id from to_delete);

\echo
\echo '# warehouse.individual'
delete from warehouse.individual where individual_id in (select individual_id from to_delete);

\echo
\echo '# warehouse.identifier'
delete from warehouse.identifier where barcode in (table sample_barcodes);

\echo
\echo '# receiving.manifest'
delete from receiving.manifest
where (document->>'sample')::citext in (table sample_barcodes)
   or (document->>'collection')::citext in (table sample_barcodes);

\echo
\echo '# receiving.clinical'
delete from receiving.clinical where document::jsonb @> jsonb_build_object('individual', :'individual');

\echo
\echo '# receiving.longitudinal'
delete from receiving.longitudinal where document::jsonb @> jsonb_build_object('individual', :'individual');

\echo
\echo '# receiving.enrollment'
delete from receiving.enrollment where document::jsonb @> jsonb_build_object('participant', :'individual');

\echo
\echo '# receiving.fhir'
delete from receiving.fhir where fhir_id in (select fhir_id from fhir_docs);

\echo
\echo '# receiving.consensus_genome'
delete from receiving.consensus_genome where document ->> 'sample_identifier' in (select sample_identifier from to_delete);

\unset individual
