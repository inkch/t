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

  set detached_session_num ( tmux list-sessions | grep -e ']$' | wc -l )

  if test $detached_session_num -eq 0
    tmux new-session
  else
    # detached session exists
    tmux list-sessions
    read -p 'echo (set_color $fish_color_comment)"Tmux: attach? y/N/num > "(set_color normal)' reply

    if string match -r '^[Yy]$' $reply; or test $reply = ''
      set detached_session_ids ( tmux list-sessions | grep -e ']$' | string match -r '^[0-9]+' )
      tmux attach -t "$detached_session_ids[1]"
      if [ $status -eq 0 ]
        echo "(tmux -V) attached session"
        return 0
      end
    else if string match -r '^[0-9]+$' $reply
      tmux attach -t "$reply"
      if [ $status -eq 0 ]
        echo "(tmux -V) attached session"
        return 0
      end
    else if string match -r '[Nn]$' $reply
      tmux new-session
      if [ $status -eq 0 ]
        echo "(tmux -V) create new session"
        return 0
      end
    else
      echo "Invalid input. Abort."
      return 0
    end
  end
end
