source concorde.bash

! true && set -o nounset

$(require_relative ../../../../context/avwob/rhel-6/user/jiff-show-mysql-slave)

describe main
  it "reports usage if not provided a command"; ( _shpec_failures=0
    result=$(main '')
    rc=$?
    [[ $result == 'Usage:'* ]]
    assert equal '0 0' "$? $rc"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end
end

describe extract
  it "finds the second word in the row which matches the specifier word"; ( _shpec_failures=0
    extract sample $'some text\nsample one\nsome text'
    assert equal one "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end

  it "only returns the first row"; ( _shpec_failures=0
    extract some $'some text\nsample one\nsome text'
    [[ $__ != *$'\n'* ]]
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end
end

describe extract_values
  it "extracts a set of values from text and returns a hash of the values"; ( _shpec_failures=0
    local -A sample_hsh=(
      [one]=some
      [two]=sample
    )
    repr sample_hsh
    extract_values "$__" $'some text\nsample lample\nsome text'
    $(local_hsh result_hsh="$__")
    assert equal '(text) (lample)' "(${result_hsh[one]}) (${result_hsh[two]})"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end
end

describe replication_report
  it "generates no errors if everything is expected"; ( _shpec_failures=0
    samples=(
      135.89.20.86
      3306
      logfile
      0
      Yes
      Yes
      logfile
      0
      135.89.20.86
      3306
    )
    replication_report "${samples[@]}"
    $(local_ary results="$__")
    assert equal 0 "${#results[@]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end

  it "errors if the host is unexpected"; ( _shpec_failures=0
    samples=(
      135.89.20.85
      3306
      logfile
      0
      Yes
      Yes
      logfile
      0
      other
      3306
    )
    replication_report "${samples[@]}"
    $(local_ary results="$__")
    assert equal 1 "${#results[@]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end

  it "errors if the port is unexpected"; ( _shpec_failures=0
    samples=(
      135.89.20.86
      3305
      logfile
      0
      Yes
      Yes
      logfile
      0
      135.89.20.86
      3306
    )
    replication_report "${samples[@]}"
    $(local_ary results="$__")
    assert equal 1 "${#results[@]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end

  it "errors if the logfile doesn't match"; ( _shpec_failures=0
    samples=(
      135.89.20.86
      3306
      logfile1
      0
      Yes
      Yes
      logfile
      0
      135.89.20.86
      3306
    )
    replication_report "${samples[@]}"
    $(local_ary results="$__")
    assert equal 1 "${#results[@]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end

  it "errors if replication is stopped"; ( _shpec_failures=0
    samples=(
      135.89.20.86
      3306
      logfile
      0
      No
      Yes
      logfile
      0
      135.89.20.86
      3306
    )
    replication_report "${samples[@]}"
    $(local_ary results="$__")
    assert equal 1 "${#results[@]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end

  it "errors if SQL replication is stopped"; ( _shpec_failures=0
    samples=(
      135.89.20.86
      3306
      logfile
      0
      Yes
      No
      logfile
      0
      135.89.20.86
      3306
    )
    replication_report "${samples[@]}"
    $(local_ary results="$__")
    assert equal 1 "${#results[@]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end

  it "errors if the slave is lagging by more than 1000"; ( _shpec_failures=0
    samples=(
      135.89.20.86
      3306
      logfile
      0
      Yes
      Yes
      logfile
      1001
      135.89.20.86
      3306
    )
    replication_report "${samples[@]}"
    $(local_ary results="$__")
    assert equal 1 "${#results[@]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? ))
  end
end
