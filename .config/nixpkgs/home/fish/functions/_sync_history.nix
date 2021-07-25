{ ... }:

{
	onEvent = "fish_postexec";
	body = ''
		history --save
		history --merge
	'';
}
