#!/bin/sh

# Check to see if we're already running the session
tmux has-session -t main &> /dev/null

if [ $? != 0 ] ; then
    # Create overall tmux session
    tmux new-session -d -s main -n java > /dev/null

    tmux split-window -v
    tmux split-window -h
    tmux send-keys -t main:1.1 "cd backends" C-m
    tmux send-keys -t main:1.2 "cd backends && vi" C-m

    # Create window for running docker-compose
    tmux new-window -n docker
    tmux send-keys -t main:2.1 "echo 'start virtualenv as you see fit'" C-m

    # Create window for running mysql client
    tmux new-window -n mariadb
    tmux split-window -v
    tmux send-keys -t main:3.1 "cd scratchpad && vim --cmd 'so dbext.vim' query.sql" C-m
    tmux send-keys -t main:3.2 "mysql -u mfg -pabc -P 3306 -h 127.0.0.1" C-m

    # Create window for running shell to connect to nosql data store
    tmux new-window -n nosql
    tmux split-window -v
    tmux send-keys -t main:4.1 "echo etcd-cli" C-m
    tmux send-keys -t main:4.2 "redis-cli -h 127.0.0.1 -p 7001 -a abc123" C-m

    # Create window for running shell for various things
    tmux new-window -n misc

else
    echo "tmux session already running, attaching..."
    sleep 2
fi

tmux select-window -t 1
tmux attach
