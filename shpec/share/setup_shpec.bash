export TMPDIR=$HOME/tmp
mkdir -p "$TMPDIR"

set -o nounset

source "$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")"/../../share/setup

describe clone_dotfiles
  # it "clones dotfiles"; ( _shpec_failures=0
  #   stub_command git
  #
  #   dir=$(mktemp -qd)
  #   clone_dotfiles "$dir" office/ubuntu-16
  #   [[ -d $dir/dotfiles/.git ]]
  #   assert equal 0 $?
  #   rm -rf -- "$dir"
  #   return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  # end

  it "sets the permissions on dotfiles"; ( _shpec_failures=0
    stub_command git

    dir=$(mktemp -qd)
    clone_dotfiles "$dir" office/ubuntu-16
    result=$(getfacl "$dir"/dotfiles 2>/dev/null)
    expected='
user::rwx
group::---
other::---
default:user::rwx
default:group::---
default:other::---'
    [[ $result == *"$expected" ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links dir_colors"; ( _shpec_failures=0
    stub_command git

    dir=$(mktemp -qd)
    clone_dotfiles "$dir" office/ubuntu-16
    [[ -h $dir/.dir_colors ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links inputrc"; ( _shpec_failures=0
    stub_command git

    dir=$(mktemp -qd)
    clone_dotfiles "$dir" office/ubuntu-16
    [[ -h $dir/.inputrc ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links gitconfig"; ( _shpec_failures=0
    stub_command git

    dir=$(mktemp -qd)
    clone_dotfiles "$dir" office/ubuntu-16
    [[ -h $dir/.gitconfig ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links gitignore_global"; ( _shpec_failures=0
    stub_command git

    dir=$(mktemp -qd)
    clone_dotfiles "$dir" office/ubuntu-16
    [[ -h $dir/.gitignore_global ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links context"; ( _shpec_failures=0
    stub_command git

    dir=$(mktemp -qd)
    clone_dotfiles "$dir" office/ubuntu-16
    [[ -h $dir/dotfiles/context ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end
end

describe create_ssh_config
  it "sets the permissions on the directory"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    create_ssh_config "$dir"
    assert equal 700 "$(stat -c %a "$dir"/.ssh)"
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "creates the config"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    create_ssh_config "$dir"
    expected='
      Host github.com
      Hostname localhost
      Port 12346'
    assert equal "${expected#$'\n'}" "$(< "$dir"/.ssh/config)"
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "sets the permissions on the config file"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    create_ssh_config "$dir"
    assert equal 600 "$(stat -c %a "$dir"/.ssh/config)"
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "updates an existing config"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    ssh=$dir/.ssh
    config=$ssh/config
    mkdir -- "$ssh"
    echo hello >"$config"
    create_ssh_config "$dir"
    expected='hello

      Host github.com
      Hostname localhost
      Port 12346'
    assert equal "${expected#$'\n'}" "$(< "$config")"
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "doesn't update a config with an existing github host"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    ssh=$dir/.ssh
    config=$ssh/config
    mkdir -- "$ssh"
    echo 'Host github.com' >"$config"
    create_ssh_config "$dir"
    expected='Host github.com'
    assert equal "${expected#$'\n'}" "$(< "$config")"
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end
end

describe setup_bashrc
  it "adds to the end of .bashrc"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    setup_bashrc "$dir"
    expected='
      bashrc=$HOME/dotfiles/bash/bashrc
      [[ -e $bashrc ]] && source "$bashrc"
      unset -v bashrc'
    assert equal "${expected#$'\n'}" "$(< "$dir"/.bashrc)"
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "adds to the end of an existing .bashrc"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    bashrc=$dir/.bashrc
    echo hello >>"$bashrc"
    setup_bashrc "$dir"
    expected='hello

      bashrc=$HOME/dotfiles/bash/bashrc
      [[ -e $bashrc ]] && source "$bashrc"
      unset -v bashrc'
    assert equal "${expected#$'\n'}" "$(< "$bashrc")"
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "doesn't add to the a .bashrc with an existing entry"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    bashrc=$dir/.bashrc
    echo 'bashrc=$HOME/dotfiles/bash/bashrc' >>"$bashrc"
    setup_bashrc "$dir"
    assert equal 'bashrc=$HOME/dotfiles/bash/bashrc' "$(< "$bashrc")"
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end
end

describe setup_liquidprompt
  it "creates the directory"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    setup_liquidprompt "$dir"
    [[ -d $dir/.config/liquidprompt ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links liquidpromptrc"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    setup_liquidprompt "$dir"
    [[ -h $dir/.config/liquidpromptrc ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links liquidprompt"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    setup_liquidprompt "$dir"
    [[ -h $dir/.config/liquidprompt/liquidprompt ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links liquid.theme"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    setup_liquidprompt "$dir"
    [[ -h $dir/.config/liquidprompt/liquid.theme ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end
end

describe setup_ssh
  it "creates the directory"; ( _shpec_failures=0
    stub_command cp

    dir=$(mktemp -qd)
    setup_ssh "$dir"
    [[ -d $dir/.ssh ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "removes config"; ( _shpec_failures=0
    stub_command cp

    dir=$(mktemp -qd)
    ssh=$dir/.ssh
    mkdir -p "$ssh"
    touch "$ssh"/config
    setup_ssh "$dir"
    [[ -e $ssh/config ]]
    assert unequal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "links dotfiles"; ( _shpec_failures=0
    stub_command cp

    dir=$(mktemp -qd)
    ssh=$dir/.ssh
    dotfiles=$dir/dotfiles/ssh
    mkdir -p "$dotfiles"
    touch "$dotfiles"/authorized_keys
    setup_ssh "$dir"
    [[ -h $ssh/authorized_keys ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end

  it "copies authorized_keys2"; ( _shpec_failures=0
    dir=$(mktemp -qd)
    ssh=$dir/.ssh
    dotfiles=$dir/dotfiles/ssh
    mkdir -p "$dotfiles"
    touch "$dotfiles"/authorized_keys
    setup_ssh "$dir"
    [[ -e $ssh/authorized_keys2 ]]
    assert equal 0 $?
    rm -rf -- "$dir"
    return "$_shpec_failures" );: $(( _shpec_failures += $? ))
  end
end

# describe clone_dotvim
#   it "clones dotfiles"; ( _shpec_failures=0
#     stub_command git
#
#     dir=$(mktemp -qd)
#     clone_dotvim "$dir"
#     [[ -d $dir/.vim/.git ]]
#     assert equal 0 $?
#     rm -rf -- "$dir"
#     return "$_shpec_failures" );: $(( _shpec_failures += $? ))
#   end
#
#   it "checks out the essential branch"; ( _shpec_failures=0
#     stub_command git
#
#     dir=$(mktemp -qd)
#     clone_dotvim "$dir"
#     result=$(cd "$dir"/.vim; git branch --list essential)
#     assert equal '* essential' "$result"
#     rm -rf -- "$dir"
#     return "$_shpec_failures" );: $(( _shpec_failures += $? ))
#   end
# end
