function mathpy
ipython --matplotlib=tk -i -c '\
prog = """
import numpy as np
from numpy import *
import scipy as sp
import scipy.constants as const
import matplotlib.pyplot as plt
import numpy.fft as fft
import scipy.signal as signal
import pint
u = pint.UnitRegistry()
""".strip("\n")
print("Executing:", *(">>> " + i for i in prog.splitlines()), sep="\n")
exec(prog)
'
end
