# Tested with ranger 1.7.0 through ranger 1.7.*
#

from __future__ import absolute_import, division, print_function

import os.path
import shlex
import subprocess
import collections

import ranger.api
import ranger.api.commands
import ranger.core.linemode
import ranger.ext.spawn

grep_cache = collections.defaultdict(int)
grep_search = None

def trace(*args, **kwargs):
	with open(os.path.expanduser('~/ranger.log'), 'a') as file:
		print(*args, **kwargs, file=file)
	return args[-1]

class grep(ranger.api.commands.Command):
	""":grep [-grep-flags] regex\n
	Grep
	"""
	def __init__(self, *args, **kwargs):
		super(grep, self).__init__(*args, **kwargs)
		_, self.flags = self.parse_flags()
	def execute(self):
		grep_cache.clear()
		global grep_search
		grep_search = self.line.split(maxsplit=1)
		if len(grep_search) == 2:
			grep_search = grep_search[1]
			if not self.fm.thistab.thisdir: return
			files = self.fm.thistab.thisdir.marked_items
			if not files: files = [self.fm.thistab.thisdir]
			cmd = ('grep --perl-regexp --dereference-recursive --null --color=never '
				+ '--binary-files=without-match --ignore-case --files-with-matches '
				+ grep_search + ' ' + shlex.join(map(str, files)))
			try:
				result = ranger.ext.spawn.check_output(cmd, stdout=subprocess.PIPE)
			except ranger.ext.spawn.CalledProcessError as err:
				if err.returncode == 1:
					result = ''
				else:
					grep_search = None
					raise
			for file in result.split('\0'):
				seen = set()
				while file not in seen:
					seen.add(file)
					grep_cache[file] += 1
					file = os.path.dirname(file)
		else:
			grep_search = None
		set_linemode(self.fm.thisdir)

@ranger.api.register_linemode
class GrepLinemode(ranger.core.linemode.DefaultLinemode):
	name = 'grep'
	uses_metadata = False
	def infostring(self, fobj, metadata):
		return str(grep_cache.get(str(fobj.path), ''))

def set_linemode(thisdir):
	if grep_search is not None:
		thisdir.set_linemode_of_children('grep')
	elif thisdir.files:
		for file in thisdir.files:
			if file.linemode == 'grep':
				file.set_linemode(ranger.core.linemode.DEFAULT_LINEMODE)

def hook_cd(signal):
	set_linemode(signal.new)

def hook_move(signal):
	os.environ.pop('RANGER_GREP', None)
	if signal.new and str(signal.new.path) in grep_cache:
		os.environ['RANGER_GREP'] = str(grep_search)

hook_init_old = ranger.api.hook_init
def hook_init(fm):
	fm.signal_bind('cd', hook_cd)
	fm.signal_bind('move', hook_move)
	return hook_init_old(fm)
ranger.api.hook_init = hook_init
