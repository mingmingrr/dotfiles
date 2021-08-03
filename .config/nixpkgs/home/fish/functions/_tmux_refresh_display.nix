{ ... }:

{
	onEvent = "fish_postexec";
	body = ''
		if set -q TMUX
			set -x (tmux showenv DISPLAY | string split =)
		end
	'';
}
