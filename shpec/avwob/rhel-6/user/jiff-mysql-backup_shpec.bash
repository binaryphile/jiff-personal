export TMPDIR=$HOME/tmp
mkdir -p "$TMPDIR"

source concorde.bash

$(grab 'mktempd rmtree' fromns concorde.macros)
$(require_relative ../../../../context/avwob/rhel-6/user/jiff-mysql-backup)

# describe mback_main
#   it ""; ( _shpec_failures=0
#     stub_command date
#     result=$(mbackup full sample)
#     get <<'    EOS'
#       --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf --all-databases --single-transaction
#     EOS
#     assert equal "$__" "$result"
#     return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
#   end
# end

describe mbackup
  it "full calls mysqldump with arguments"; ( _shpec_failures=0
    stub_command mysqldump        'echo "$@"'
    stub_command gzip             cat
    stub_command redirect_to_file cat
    stub_command date
    get <<'    EOS'
      --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf --all-databases --single-transaction
    EOS
    assert equal "$__" "$(mbackup full sample)"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "master calls mysqldump with arguments"; ( _shpec_failures=0
    stub_command mysqldump        'echo "$@"'
    stub_command gzip             cat
    stub_command redirect_to_file cat
    stub_command date
    get <<'    EOS'
      --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf --master-data --single-transaction avwob_production
    EOS
    assert equal "$__" "$(mbackup master sample)"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe redirect_to_file
  it "redirects piped output to a file"; ( _shpec_failures=0
    dir=$($mktempd)
    [[ -d $dir ]] || return
    echo hello | redirect_to_file "$dir"/hola
    assert equal hello "$(< "$dir"/hola)"
    $rmtree "$dir"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe timestamp
  it "generates a timestamp in the format YYYY-MM-DD-HHMM"; ( _shpec_failures=0
    stub_command date 'echo "$@"'
    result=$(timestamp)
    assert equal +%Y-%m-%d-%H%M "$(timestamp)"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end
