from __future__ import unicode_literals, division, absolute_import, print_function

from powerline.segments import Segment, with_docstring
from powerline.theme import requires_segment_info, requires_filesystem_watcher

import subprocess
import os
import stat
import hashlib

@requires_segment_info
def environment(pl, segment_info, variable=None, contents=None):
	'''
	Return the value of any defined environment variable\n
	This is a modified version of
	:func:`powerline.segments.common.env.environment`.
	Useful for checking the existance of a variable
	without displaying its contents.\n
	:param variable: The environment variable to return if found
	:type variable: string
	:param contents: The variable value will be overridden by this if set
	:type contents: string, optional
	'''
	var = segment_info['environ'].get(variable, None)
	if var is None: return None
	if contents is None: return var
	return contents

@requires_filesystem_watcher
@requires_segment_info
def python(pl, segment_info, create_watcher, code=None):
	'''
	Return a value set by an arbitrary python block\n
	The resulting value should be stored in a variable named ``result``.\n
	:param code: A Python code block to be passed to :func:`exec`
	:type code: string
	'''
	assert code is not None
	scope = {'pl': pl,
		'segment_info': segment_info,
		'create_watcher': create_watcher}
	exec(code, None, scope)
	return scope.get('result', None)

@requires_segment_info
def shell(pl, segment_info, code=None):
	'''
	Return the stdout of an arbitrary executable\n
	The executables are cached in $XDG_DATA_HOME/powerline/shell_cache
	:param code: An executable passed to be executed by the system
	:type code: string
	'''
	assert code is not None
	cache_dir = os.path.join(os.environ.get('XDG_DATA_HOME',
		os.path.join(os.path.expanduser('~'),
			'.local', 'share')), 'powerline', 'shell_cache')
	if not os.path.isdir(cache_dir):
		os.makedirs(cache_dir)
	cache_file = os.path.join(cache_dir,
		hashlib.sha224(code.encode('utf-8')).hexdigest())
	if not os.path.isfile(cache_file):
		with open(cache_file, 'w') as file:
			file.write(code)
		os.chmod(cache_file, os.stat(cache_file).st_mode | stat.S_IEXEC)
	return command(pl, segment_info, args=[cache_file])

@requires_segment_info
def command(pl, segment_info, args=None):
	'''
	Return the stdout of a command\n
	:param code: An executable passed to be executed by the system
	:type code: string
	'''
	assert args is not None
	return subprocess.run(args,
		check=True,
		capture_output=True,
		env=segment_info['environ']
	).stdout

@requires_filesystem_watcher
@requires_segment_info
def colored(pl, segment_info, create_watcher, code=None, highlight=None):
	'''
	Return a value set by an arbitrary python block colored by ``client_id``\n
	Similar to :func:`powerline_contrib.segments.common.python`,
	but the background color is semi-randomized based on ``client_id``.\n
	:param code: A Python code block to be passed to ``exec``
	:type code: string
	:param highlight: Names of highlight groups to be used
	:type highlight: list, optional
	'''
	result = python(pl, segment_info, create_watcher, code)
	if result is None:
		return None
	if isinstance(result, str):
		result = [{'contents': result}]
	if isinstance(result, dict):
		result = [{'contents': result}]
	return [dict(
		highlight_groups=highlight or ['colored_gradient'],
		gradient_level=((150 + 12500**0.5)
			* hash(segment_info.get('client_id', 0))) % 100,
		**item
	) for item in result]

