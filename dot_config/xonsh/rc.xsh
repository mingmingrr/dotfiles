# vim: set ts=2 sw=0 sts=0 noet nowrap ft=xonsh:

$INDENT                       = '  '
# $XONSH_SHOW_TRACEBACK         = True
$CASE_SENSITIVE_COMPLETIONS   = False
# $AUTO_SUGGEST_IN_COMPLETIONS  = True
# $MOUSE_SUPPORT                = True
$HISTCONTROL                  = set(['erasedups'])
$XONSH_HISTORY_BACKEND        = 'sqlite'
$XONSH_HISTORY_MATCH_ANYWHERE = True
$MULTILINE_PROMPT             = ' '
# $SUBSEQUENCE_PATH_COMPLETION  = False
# $XONSH_STDERR_PREFIX          = '{RED}'
# $XONSH_STDERR_POSTFIX         = '{RESET}'
# $UPDATE_OS_ENVIRON            = False
$XONSH_SHOW_TRACEBACK         = True

import os
import shutil
import site
import subprocess
import sys
import tempfile
import time
import venv
import warnings

def update_xontribs(force=False):
	venv_path = p'$XDG_DATA_HOME/xonsh/venv' / sys.implementation.cache_tag
	if not venv_path.exists(): venv.create(venv_path, with_pip=True)
	sys.path.append(str(venv_path / f'lib/python{sys.version_info.major}.{sys.version_info.minor}/site-packages'))
	xontrib_reqs = p'$XDG_CONFIG_HOME/xonsh/xontribs.txt'
	mtime_marker = venv_path.joinpath('mtime')
	update = force
	if not xontrib_reqs.exists(): pass
	elif not mtime_marker.exists(): update = True
	elif xontrib_reqs.stat().st_mtime > mtime_marker.stat().st_mtime: update = True
	elif time.time() > mtime_marker.stat().st_mtime + 14*24*60*60: update = True
	if not update: return
	@(venv_path)/bin/pip -v install --upgrade --requirement @(xontrib_reqs)
	touch @(mtime_marker)

def _interactive_config(*_, **__):
	source-foreign --sourcer source bash ~/.nix-profile/etc/profile.d/hm-session-vars.sh

	@events.on_postcommand
	def suppress_warnings(*args, **kwargs):
		warnings.filterwarnings('ignore',
			category=DeprecationWarning)
	suppress_warnings()

	update_xontribs()

	xontrib load coreutils
	xontrib load direnv
	xontrib load powerline_binding
	xontrib load fish_completer
	$XONTRIB_CD_LONG_DURATION = 2
	xontrib load cmd_done
	$fzf_history_binding = 'c-r'
	xontrib load fzf-widgets
	xontrib load term_integration
	xontrib load psub
	xontrib load broot

	# $SHELL = sys.argv[0]
	# $SHELL = shutil.which('xonsh')

	@events.on_ptk_create
	def custom_keybindings(bindings, **kwargs):
		from xonsh.shells.ptk_shell.key_bindings import ctrl_d_condition
		from prompt_toolkit.keys import Keys
		from prompt_toolkit.filters import HasSelection
		from prompt_toolkit.key_binding.bindings.named_commands import backward_kill_word
		from prompt_toolkit.application.run_in_terminal import run_in_terminal

		@bindings.add(Keys.ControlX, eager=True, filter=~HasSelection())
		async def open_in_editor(event):
			header = '# vim: set ft=xonsh sw=0 sts=0 et ts={}:'.format(len($INDENT))
			buff = event.cli.current_buffer
			buff.text = header + '\n' + buff.text
			await buff.open_in_editor()
			if buff.text.startswith(header):
				buff.text = buff.text[len(header):].strip('\n')

		@bindings.add(Keys.ControlD, filter=ctrl_d_condition)
		def call_exit_alias(event):
			event.cli.current_buffer.text = 'exit 0'
			event.cli.current_buffer.cursor_position = 6

		@bindings.add(Keys.ControlW, filter=~HasSelection())
		def delete_word(event):
			backward_kill_word(event)

		@bindings.add(Keys.ControlN, filter=~HasSelection())
		async def navigate_ranger(event):
			try:
				tmp = tempfile.NamedTemporaryFile(delete=False)
				await run_in_terminal(in_executor=True,
					func=lambda: subprocess.call(['ranger', '--choosedir', tmp.name]))
				with open(tmp.name) as file:
					text = os.path.relpath(file.read().rstrip('\n'), $PWD)
			finally:
				os.unlink(tmp.name)
			buff = event.cli.current_buffer
			if not buff.text:
				text = 'cd ' + text
			buff.text += text
			buff.cursor_position += len(text)

	@events.on_precommand
	def set_window_id(cmd=''):
		if ${...}.get('DISPLAY') and shutil.which('xprop'):
			$WINDOWID = subprocess.run(['xprop', '-root', '32i', '_NET_ACTIVE_WINDOW'],
				text=True, capture_output=True).stdout.strip().split()[-1]
		else:
			$WINDOWID = 99999999
	set_window_id()

	@events.on_pre_prompt
	def _long_cmd_duration():
		long_cmd_duration()

	@events.on_pre_prompt
	def _history_pull():
		with open(os.devnull, 'w') as devnull:
			__xonsh__.history.pull()

	@events.on_chdir
	def ls_on_cd(olddir, newdir):
		env LC_ALL=C ls -1 -A @(newdir) \
			'--group-directories-first' '--color=always' | tabulate

	if 'TMUX' in ${...}:
		@events.on_precommand
		def tmux_refresh_display(cmd):
			$DISPLAY = $(tmux showenv DISPLAY).split('=', 1)[1].strip()

	$LS_COLORS = eval($(dircolors --csh ~/.config/dircolors).strip().split(' ', 2)[2])

_interactive_config()

aliases['n'] = ['sed', '-z', '$ s/\\n$//']

@events.on_chdir
def _cdh_on_chdir(olddir, newdir):
	if olddir in _cdh_on_chdir_history:
		prev, next = _cdh_on_chdir_history[olddir]
		_cdh_on_chdir_history[prev][1] = next
		_cdh_on_chdir_history[next][0] = prev
	last = _cdh_on_chdir_history[None][0]
	_cdh_on_chdir_history[olddir] = [last, None]
	_cdh_on_chdir_history[last][1] = olddir
	_cdh_on_chdir_history[None][0] = olddir
_cdh_on_chdir_history = { $PWD: [None, None], None: [$PWD, $PWD] }

@aliases.register('cdh')
def _cdh(args, stdin=None, stdout=None, stderr=None):
	import argparse
	parser = argparse.ArgumentParser(prog='cdh')
	parser.add_argument('index', type=int, nargs='?', default=None)
	args = parser.parse_args(args)

	if len(_cdh_on_chdir_history) == 1:
		print('No previous directories to select.',
			'You have to cd at least once.', file=stderr)
		return 0

	def toStr(n, ds):
		if n == 0: return ds[0]
		xs = []
		while n:
			n, m = divmod(n, len(ds))
			xs.append(ds[m])
		return ''.join(reversed(xs))

	node, dirs = _cdh_on_chdir_history[None][1], []
	while node is not None:
		dirs.append(node)
		node = _cdh_on_chdir_history[node][1]

	import string
	alphaLen = len(toStr(len(dirs), string.ascii_lowercase))
	digitLen = len(toStr(len(dirs), string.digits))
	choices = dict()
	for index, node in enumerate(dirs):
		if node.startswith($HOME):
			node = '~' + node[len($HOME):]
		alphas = toStr(len(dirs) - index - 1, string.ascii_lowercase)
		digits = toStr(len(dirs) - index, string.digits)
		choices[alphas] = choices[digits] = node
		print(' {} {}) {}'.format(alphas, digits, node), file=stdout)

	choice = input('Select directory by letter or number: ').lower()
	if not choice: return 0
	if choice not in choices:
		print('Error: expected a number between 1 and ' + str(len(dirs))
			+ ' or letter in that range, got ' + repr(select), file=stderr)
		return 1

	cd @(choices[choice])
	return 0

