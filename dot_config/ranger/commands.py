from __future__ import absolute_import, division, print_function

import re
import os
import tempfile
import shlex
import stat
import textwrap

import ranger.api.commands

batch_cache = {}

class batch(ranger.api.commands.Command):
	''':batch <flags=w>\n
	The batch command writes the currently selected filenames to a file, which
	will be executed. This is useful for running a shell command on multiple
	files.
	'''
	def __init__(self, *args, **kwargs):
		super(batch, self).__init__(*args, **kwargs)
		self.flags, _ = self.parse_flags()
		if not self.flags: self.flags = 'w'
	def execute(self):
		from ranger.container.file import File
		cache_key = tuple(sorted(file.path
			for file in self.fm.thistab.get_selection()))
		contents = ['#!/usr/bin/env bash', 'set -o errexit', 'set -o xtrace']
		for file in self.fm.thistab.get_selection():
			contents.append(shlex.quote(file.relative_path))
		contents.append('')
		contents.append(textwrap.indent(batch_cache.get(cache_key, ''), '# '))
		contents = '\n'.join(contents)
		with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as script:
			script.write(contents)
		try:
			self.fm.execute_file([File(script.name)], app='editor')
			with open(script.name, 'r') as reading:
				modified = reading.read()
				if modified == contents: return
			batch_cache[cache_key] = modified
			os.chmod(script.name, os.stat(script.name).st_mode | stat.S_IEXEC)
			self.fm.run([script.name], flags=self.flags)
		finally:
			os.unlink(script.name)
		self.fm.reload_cwd()

def _exit_no_work(self):
	preview = self.fm.settings.preview_script
	if any(work.args[0] != preview for work in self.fm.loader.queue):
		self.fm.notify('Not quitting: Tasks in progress: Use `quit!` to force quit')
	else:
		self.fm.exit()

class quit_scope(ranger.api.commands.Command):
	""":quit_scope\n
	Closes the current tab, if there's more than one tab.
	Otherwise quits if there are no tasks other than scope.sh in progress.
	"""
	def execute(self):
		if len(self.fm.tabs) > 1:
			self.fm.tab_close()
		else:
			_exit_no_work(self)

class quitall_scope(ranger.api.commands.Command):
	""":quitall_scope\n
	Quits if there are no tasks other than scope.sh in progress.
	"""
	def execute(self):
		_exit_no_work(self)

class set_env(ranger.api.commands.Command):
	""":set_env <setting> [<envvar> <envval> <value>]* <fallback>\n
	Run `:set x y` based on environment variables
	"""
	def execute(self):
		setting, *values, fallback = shlex.split(self.rest(1))
		for k, v, x in zip(*([iter(values)]*3)):
			if os.getenv(k) == v: break
		else: x = fallback
		self.fm.settings[setting] = x

class paste_num(ranger.api.commands.Command):
	""":paste_num [relative|symlink|hardlink|hardlinked_subtree]\n
	Like paste but tries to rename conflicting files so that the
	file extension stays intact (e.g. file.1.ext).
	"""
	regex = re.compile(r'\.\d+$')
	def __init__(self, *args, **kwargs):
		super(paste_num, self).__init__(*args, **kwargs)
		_, self.flags = self.parse_flags()
	@classmethod
	def split_extension(cls, dst):
		name, ext = os.path.splitext(dst)
		if cls.regex.match(ext) is not None:
			return name, int(name[1:]), ''
		match = cls.regex.search(name)
		if match is not None:
			return name[:match.start()], int(match[0][1:]), ext
		return name, 0, ext
	@classmethod
	def make_safe_path(cls, dst):
		if not os.path.exists(dst): return dst
		name, index, ext = cls.split_extension(dst)
		while True:
			index += 1
			test_dst = '{}.{}{}'.format(name, index, ext)
			if not os.path.exists(test_dst): break
		return test_dst
	def execute(self):
		func, *args = self.flags.strip().split()
		kwargs = {}
		for arg in args:
			k, v = arg.split('=', maxsplit=1)
			kwargs[k] = eval(v)
		return getattr(self.fm, func)(make_safe_path=self.make_safe_path, **kwargs)

