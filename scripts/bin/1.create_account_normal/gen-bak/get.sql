select name
from chain_stats.account_info
where creator = 'bbp'
  and name >= 'caaav.bbp' and length(name) = 9 order by name limit 3000