#!/bin/bash

PROJECT_ROOT="$HOME/dev/sweaty_wallet"
SESSION_NAME="sweaty_wallet"
WINDOWS=(
  docker
  main_app
  claude
  extension
  lazygit
  terminal
)

tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? != 0 ]; then
  for window in "${WINDOWS[@]}"; do
    if [ "$window" == "docker" ]; then
      tmux new-session -d -s $SESSION_NAME -n $window
    else
      tmux new-window -t $SESSION_NAME -n $window
    fi
  done
  tmux send-keys -t $SESSION_NAME:"${WINDOWS[0]}" "cd $PROJECT_ROOT && docker compose up --build" C-m
  tmux send-keys -t $SESSION_NAME:"${WINDOWS[1]}" "cd $PROJECT_ROOT/main_app && vim" C-m
  tmux send-keys -t $SESSION_NAME:"${WINDOWS[2]}" "cd $PROJECT_ROOT && claude" C-m
  tmux send-keys -t $SESSION_NAME:"${WINDOWS[3]}" "cd $PROJECT_ROOT/chrome_extension && vim" C-m
  tmux send-keys -t $SESSION_NAME:"${WINDOWS[4]}" "cd $PROJECT_ROOT && lazygit" C-m
  tmux send-keys -t $SESSION_NAME:"${WINDOWS[5]}" "cd $PROJECT_ROOT" C-m

  tmux select-window -t $SESSION_NAME:"${WINDOWS[1]}"
fi

tmux attach-session -t $SESSION_NAME
