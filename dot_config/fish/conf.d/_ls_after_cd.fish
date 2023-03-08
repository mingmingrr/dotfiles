function _ls_after_cd --on-variable PWD
	if not status --is-interactive; return; end
	if status --is-command-substitution; return; end
	ls -1 --group-directories-first --almost-all --color=always | tabulate
end
