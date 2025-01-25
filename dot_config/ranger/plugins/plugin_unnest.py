# Requires modified plugin_ipc that sets $RANGER_IPC_FIFO
#
# This plugin detects nested ranger instances and flattens the nesting by
# passing a cd command to the parent ranger instance.

from __future__ import absolute_import, division, print_function

import ranger.api
import os

def unnest_ranger(fm):
	# Navigate to current directory on parent ranger
	for fifo in os.environ.get('RANGER_IPC_FIFO', '').split():
		if fifo.split('.')[-1] == str(os.getpid()): continue
		with open(fifo, 'w') as file:
			file.write('cd ' + fm.start_paths[0])
		# os.kill(os.getppid(), signal.SIGTERM)
		break

	def display_message():
		print('nested ranger detected, exit shell or unset $RANGER_LEVEL to continue')
	import atexit
	atexit.register(display_message)

	raise SystemExit

hook_init_old = ranger.api.hook_init
def hook_init(fm):
	try:
		level = int(os.environ.get('RANGER_LEVEL', '0'))
	except ValueError:
		level = 0
	if level > 1:
		unnest_ranger(fm)
	hook_init_old(fm)
ranger.api.hook_init = hook_init
