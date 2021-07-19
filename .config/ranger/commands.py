from __future__ import absolute_import, division, print_function

import os
import tempfile
import shlex
import stat

from ranger.api.commands import Command

class batch(Command):
	''':batch <flags=w>

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
		from ranger.ext.shell_escape import shell_escape as esc
		contents = b'#!/usr/bin/env bash\n'
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

