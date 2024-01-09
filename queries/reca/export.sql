select
    rowid,
    name,
    admin_level,
    boundary,
    [felt:color] as 'fill',
    case
        [felt:color]
        when '#E8B500' then 'uranium'
        when '#2674BA' then 'expansion'
        when '#E76D02' then 'downwind'
    end layer,
    geometry
from
    areas