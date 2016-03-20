## My Personal Jiff

This is not the [jiff] repo, if that's what you're looking for.  To use
jiff for yourself, go there and read about installation.

This repo is for my own jiff tasks.  This readme is a how-to on what
they are and how to use them.

For background on jiff, see the [jiff readme].

## What Jiff Is

To summarize from there:

[Jiff] is an automation notebook.  Jiff helps you turn your command-line
system configuration rituals into simple tasks, available wherever you
need them.

Jiff makes available a command, "jiff", which allows you to create
subcommands called tasks (e.g. "jiff mytask").  Jiff makes it simple to
create new tasks by providing a basic script template that also pulls in
your bash history, so you can capture whatever it is you just finished
working on.

Jiff tasks are not limited to scripts.  They can be any executable,
although it is tailored for scripting.

## Installation

### AVWOB

On the AVWOB machines, jiff is already installed, it just needs to be
enabled for your account.  To do this, run:

```
/opt/app/avwobt4/cellar/bin/jiff init user
```

It will backup and replace your bash init files.  As an added bonus,
you'll get [liquidprompt] for your prompt.  See below for some details
on liquidprompt.

Installation on a new AVWOB machine has to be done manually until I
write the script for it.  It's very different from the existing scripts
because it's installed in a shared directory (`/opt/app/avwobt4`), but
not with administrative privileges.

### Peak 10

In the datacenter, jiff is already installed globally on any of the
machines I work on.  It should be automatically available to you, as it
is loaded in the default bash startup files.

If it's not available on one of those machines, it probably means I
haven't worked on it.  If so, you can install it with the following:

```
curl -sL https://raw.githubusercontent.com/binaryphile/jiff-personal/master/install-jiff-admin | bash
```

Since your shell on those machines is bash, you probably won't have to
log off and on, but if jiff isn't available at all, do that.  Then run:

```
jiff set context peak10
```

### ARMT

TBD

### Office

For machines in the office, such as your personal machine, you can
install jiff on your personal account with the following:

```
curl -sL https://raw.githubusercontent.com/binaryphile/jiff-personal/master/install-jiff | bash
```

If you don't use bash as your shell (likely), you'll need to follow the
basher instructions for [modifying your shell config] to make basher
available (and jiff, by extension).

You'll probably need to log off and on to make jiff available.  Then
run:

```
jiff set context office
```

If you run ubuntu 14 or 15 as your desktop, that will make many of my
tasks available.  Otherwise you'll start with a pretty blank slate.

## Shared Usage

Currently on any of the preinstalled jiff machines, everyone has full
run of the shared installation.  So don't change the context or user
role without knowing what you're doing and without telling others.

It's planned to make jiff more multiuser-friendly but that's low on the
priority list.

[jiff]: https://github.com/binaryphile/jiff
[jiff readme]: https://github.com/binaryphile/jiff/blob/master/README.md
[liquidprompt]: https://github.com/nojhan/liquidprompt
