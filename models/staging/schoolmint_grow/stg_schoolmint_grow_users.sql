
select
    json_value(data, '$._id')                                as user_id,
    json_value(data, '$.name')                               as name,
    json_value(data, '$.email')                              as email,
    json_value(data, '$.hidden')                             as hidden,
    cast(json_value(data, '$.inactive') as bool)             as inactive,
    cast(json_value(data, '$.locked') as bool)               as locked
from {{ source('staging', 'base_schoolmint_grow_users') }}
where
    date_extracted = (select max(date_extracted) from {{ source('staging', 'base_schoolmint_grow_users') }})
