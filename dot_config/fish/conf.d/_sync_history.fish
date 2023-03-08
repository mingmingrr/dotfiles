function _sync_history --on-event fish_postexec
	history save
	history merge
end
