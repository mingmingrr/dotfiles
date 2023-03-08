function fish_prompt
  powerline shell aboveleft \
    --last-exit-code $status \
    --last-pipe-status "$pipestatus" \
    --jobnum (jobs -p | wc -l) \
    --width (stty size | cut -d ' ' -f 2) \
    --renderer-arg client_id=$fish_pid \
    --renderer-arg mode=$fish_bind_mode \
    --renderer-arg default_mode=default
end
