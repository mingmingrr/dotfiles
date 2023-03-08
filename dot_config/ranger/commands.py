from __future__ import absolute_import, division, print_function

import os
import tempfile
import shlex
import stat

import ranger.api.commands

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
		contents = b'#!/usr/bin/env bash\nset -o errexit\nset -o xtrace\n'
		for file in self.fm.thistab.get_selection():
			file = shlex.quote(file.relative_path)
			contents += (file + '\n').encode('utf-8', 'surrogateescape')
		try:
			with tempfile.NamedTemporaryFile(mode='wb', suffix='.sh', delete=False) as script:
				script.write(contents)
			self.fm.execute_file([File(script.name)], app='editor')
			with open(script.name, 'rb') as reading:
				if reading.read() == contents: return
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

