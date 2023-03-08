if status --is-interactive
	set fish_features \
		qmark-noglob \
		stderr-nocaret \
		ampersand-nobg-in-token \
		regex-easyesy

	set __done_min_cmd_duration 1000
	set __done_notification_urgency_level normal

	if type -q direnv
		direnv hook fish | source
	end

	if set -q KITTY_INSTALLATION_DIR
		set --local dir "$KITTY_INSTALLATION_DIR/shell-integration/fish"
		set --global KITTY_SHELL_INTEGRATION enabled
		source "$dir/vendor_conf.d/kitty-shell-integration.fish"
		set --prepend fish_complete_path "$dir/vendor_completions.d"
	end

	if set -q TMUX
		function _tmux_refresh_display --on-event fish_preexec
			set -x DISPLAY (tmux showenv DISPLAY | string replace DISPLAY= '')
		end
	end

	if type -q powerline-setup
		if begin type -q powerline; or set -q POWERLINE_COMMAND; end
			powerline-setup
		end
	end
end
