source concorde.bash

$(require_relative ../../../../context/avwob/rhel-6/user/jiff-mysql-sync)

describe msync_main
  it "reports usage if not provided a slave argument"; ( _shpec_failures=0
    result=$(msync_main '')
    rc=$?
    [[ $result == $'\nUsage:'* ]]
    assert equal '0 0' "$? $rc"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "calls msync when given --dry-run"; ( _shpec_failures=0
    stub_command msync 'echo "$@"'
    dry_run_flag=1
    stuff dry_run_flag into ''
    assert equal 'sample __' "$(msync_main __ sample)"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "calls msync when given a master"; ( _shpec_failures=0
    stub_command msync 'echo "$@"'
    assert equal 'sample __' "$(msync_main '' sample example)"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe msync
  it "reports the command when given dry_run_flag with only slave"; ( _shpec_failures=0
    get <<'    EOS'
      mysqldump --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf --single-transaction --master-data avwob_production | mysql --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf -h sample avwob_production
    EOS
    assert equal "$__" "$(msync sample dry_run_flag=1)"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "reports the command when given dry_run_flag with slave and master"; ( _shpec_failures=0
    get <<'    EOS'
      mysqldump --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf --single-transaction --master-data -h example avwob_production | mysql --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf -h sample avwob_production
    EOS
    assert equal "$__" "$(msync sample dry_run_flag=1 master=example)"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "calls mysqldump with a slave argument"; ( _shpec_failures=0
    stub_command mysqldump  'echo "$@"'
    stub_command mysql      cat
    get <<'    EOS'
      --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf --single-transaction --master-data avwob_production
    EOS
    assert equal "$__" "$(msync sample '')"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "calls mysql with a slave argument"; ( _shpec_failures=0
    stub_command mysqldump
    stub_command mysql 'echo "$@"'
    get <<'    EOS'
      --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf -h sample avwob_production
    EOS
    assert equal "$__" "$(msync sample '')"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "calls mysqldump with slave and master arguments"; ( _shpec_failures=0
    stub_command mysqldump  'echo "$@"'
    stub_command mysql      cat
    result=$(msync sample master=example)
    get <<'    EOS'
      --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf --single-transaction --master-data -h example avwob_production
    EOS
    assert equal "$__" "$result"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "calls mysql with a master and slave argument"; ( _shpec_failures=0
    stub_command mysqldump
    stub_command mysql 'echo "$@"'
    get <<'    EOS'
      --defaults-extra-file=/opt/app/avwobt4/etc/mysql/backup.cnf -h sample avwob_production
    EOS
    assert equal "$__" "$(msync sample '')"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end
