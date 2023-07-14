
select
    json_value(data, '$._id')                                as observation_id,
    json_value(data, '$.teacher')                            as teacher_user_id,
    json_value(data, '$.observer')                           as observer_user_id,
    json_value(data, '$.observationType')                    as observation_type_id,
    json_value(data, '$.quickHits')                          as quick_hits,
    parse_timestamp('%Y-%m-%dT%H:%M:%E*SZ', json_value(data, '$.observedAt'))   as observed_at,
    cast(json_value(data, '$.score') as float64)             as score,
    cast(json_value(data, '$.scoreAveragedByStrand') as float64)                as score_averaged_by_strand,
    cast(json_value(data, '$.isPublished') as bool)            as is_published,
    cast(json_value(data, '$.isPrivate') as bool)              as is_private,
    array(
        select as struct 
            json_value(scores, "$.measurement")                as measurement_id,
            json_value(scores, "$.measurementGroup")           as measurement_group,
            cast(json_value(scores, "$.valueScore") as float64)  as value_score,
            json_value(scores, "$.valueText")                   as value_text,
            json_value(scores, "$.percentage")                  as percentage,
            array(
              select as struct
                json_value(checkbox, "$.label")                as label,
                cast(json_value(checkbox, "$.value") as bool)  as value
              from unnest(json_query_array(scores, "$.checkboxes")) checkbox
            ) as checkboxes,
            array(
              select as struct
                json_value(text_box, "$.label")                as label,
                json_value(text_box, "$.text")                  as text
              from unnest(json_query_array(scores, "$.textBoxes")) text_box
            ) as text_boxes
        from unnest(json_query_array(data, "$.observationScores")) scores 
    ) as observation_scores,
    array(
        select as struct 
            parse_timestamp('%Y-%m-%dT%H:%M:%E*SZ', json_value(note, '$.created'))   as created,
            json_value(note, "$.text")                       as text,
            cast(json_value(note, "$.shared") as bool)       as shared
        from unnest(json_query_array(data, "$.magicNotes")) note 
    ) as magic_notes,
from {{ source('staging', 'base_schoolmint_grow_observations') }}
where
    date_extracted = (select max(date_extracted) from {{ source('staging', 'base_schoolmint_grow_observations') }})
