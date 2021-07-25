{ ... }:

{
	onVariable = "PWD";
	body = ''
		if begin status --is-interactive; and not status --is-command-substitution; end
			ls --all --human-readable
		end
	'';
}
