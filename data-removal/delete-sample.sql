-- This script requires that "\set sample ..." has been run first.

begin;

create temporary table to_delete on commit drop as
    select distinct
        sample.sample_id,
        presence_absence_id,
        sequence_read_set.sequence_read_set_id,
        consensus_genome.consensus_genome_id,
        genomic_sequence_id,
        sample.identifier as sample_identifier

    from warehouse.sample
    left join warehouse.presence_absence using (sample_id)
    left join warehouse.sequence_read_set on sample.sample_id = sequence_read_set.sample_id
    left join warehouse.consensus_genome on sample.sample_id = consensus_genome.sample_id
    left join warehouse.genomic_sequence using (consensus_genome_id)

    where sample.identifier = :'sample'
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
\echo '# warehouse.identifier'
delete from warehouse.identifier where barcode in (table sample_barcodes);

\echo
\echo '# receiving.manifest'
delete from receiving.manifest
where (document->>'sample')::citext in (table sample_barcodes)
   or (document->>'collection')::citext in (table sample_barcodes);

\echo
\echo '# receiving.consensus_genome'
delete from receiving.consensus_genome where document ->> 'sample_identifier' in (select sample_identifier from to_delete);

\unset sample
