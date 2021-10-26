set fish_greeting
set fish_features qmark-noglob stderr-nocaret

set __done_min_cmd_duration 1000
set __done_notification_urgency_level normal

if set -q TMUX
	function _tmux_refresh_display --on-event fish_preexec
		set -x DISPLAY (tmux showenv DISPLAY | string replace DISPLAY= '')
	end
end

