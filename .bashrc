#!/bin/bash

alias make.tar='tar -cf' # <dst> <src>
alias add.tar='tar -rf' # <dst> <src>
alias update.tar='tar -uf' # <dst> <src>
alias list.tar='tar -tf' # <dst> <src>
alias un.tar='tar -xf' # <dst> <src>

alias make.tar.gz='tar -czf' # <dst> <src>
alias add.tar.gz='tar -rzf' # <dst> <src>
alias update.tar.gz='tar -uzf' # <dst> <src>
alias list.tar.gz='tar -tzf' # <dst> <src>
alias un.tar.gz='tar -xzf' # <dst> <src>

function psg {
    ps ax | grep $1
}
