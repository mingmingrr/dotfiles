# Tested with ranger 1.7.0 through ranger 1.7.*
#
# This plugin creates a FIFO in /tmp/ranger-ipc.<PID> to which any
# other program may write. Lines written to this file are evaluated by
# ranger as the ranger :commands.
#
# Example:
#   $ echo tab_new ~/images > /tmp/ranger-ipc.1234

from __future__ import absolute_import, division, print_function

import ranger.api

def make_ipc_fifo(fm):
	# Create a FIFO.
	import os
	ipc_fifo = '/tmp/ranger-ipc.' + str(os.getpid())
	os.mkfifo(ipc_fifo)

	# Prepend env var
	ipc_var = 'RANGER_IPC_FIFO'
	ipc_env = ipc_fifo
	if ipc_var in os.environ:
		ipc_env += ' ' + os.environ[ipc_var]
	os.environ[ipc_var] = ipc_env

	# Remove the FIFO on ranger exit.
	def ipc_cleanup(filepath):
		try:
			os.unlink(filepath)
		except IOError:
			pass
	import atexit
	atexit.register(ipc_cleanup, ipc_fifo)

	# Start the reader thread.
	try:
		import thread
	except ImportError:
		import _thread as thread
	def ipc_reader(filepath):
		while True:
			with open(filepath, 'r') as fifo:
				line = fifo.read()
				fm.execute_console(line.strip())
	thread.start_new_thread(ipc_reader, (ipc_fifo,))

hook_init_old = ranger.api.hook_init
def hook_init(fm):
	try:
		make_ipc_fifo(fm)
	except IOError:
		pass # IPC support disabled
	finally:
		hook_init_old(fm)
ranger.api.hook_init = hook_init

