# Requires modified plugin_ipc that sets $RANGER_IPC_FIFO
#
# This plugin detects nested ranger instances and flattens the nesting by
# passing a cd command to the parent ranger instance.

from __future__ import absolute_import, division, print_function

import ranger.api
import os
import signal

def unnest_ranger(fm):
	pid = str(os.getpid())
	for fifo in os.environ.get('RANGER_IPC_FIFO', '').split():
		if fifo.split('.')[-1] != pid:
			with open(fifo, 'w') as file:
				file.write('cd ' + fm.start_paths[0])
			os.kill(os.getppid(), signal.SIGTERM)
			raise SystemExit

hook_init_old = ranger.api.hook_init
def hook_init(fm):
	unnest_ranger(fm)
	hook_init_old(fm)
ranger.api.hook_init = hook_init
