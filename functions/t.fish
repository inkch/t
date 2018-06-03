function t -d "tmux attacher"
  # tmux is required.
  if not test ( which tmux )
    echo 'Error: tmux command not found' 2>&1
    return 1
  end

  # screen is running, or tmux is already running.
  if test $TERM = "screen-256color"; or test $TMUX
    echo (set_color $fish_color_comment)"tmux already attached!"(set_color normal)
    return 0
  end

  # in ssh connection.
  if test $SSH_CONNECTION
    echo "SSH_CONNECTION IS DETECTED. ABORT."
    return 0
  end

  set detached_sessions ( tmux list-sessions | string match -r '^(?!.*attached).*$' )

  # detached session NOT exists
  if test ( count $detached_sessions ) -eq 0
    tmux new-session
    return 0
  end

  # detached session exists
  tmux list-sessions # show list on console
  # read param from std input
  read -p 'echo (set_color $fish_color_comment)"Tmux: attach? (y/n/num/name) > "(set_color normal)' reply

  if string match -r '^[Yy]$' $reply; or test $reply = ''
    # input is 'y', 'Y', or '', attach session in top of list.
    tmux attach -t ( string match -r '^.*:' $detached_sessions[1] )
    if [ $status -eq 0 ]
      echo "(tmux -V) attached session"
      return 0
    end
  else if string match -r '^[Nn]$' $reply
    # input is 'n', 'N', create new session and attach
    tmux new-session
    if [ $status -eq 0 ]
      echo "(tmux -V) create new session"
      return 0
    end
  else
    # input is a number, attach specified session.
    tmux attach -t "$reply"
    if [ $status -eq 0 ]
      echo "(tmux -V) attached session"
      return 0
    else
      echo "Invalid input. Abort."
      return 1
    end
  end
end
