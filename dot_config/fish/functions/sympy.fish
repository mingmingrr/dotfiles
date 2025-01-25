function sympy
ipython --matplotlib=tk -i -c '\
prog = """
import sympy
try: import scipy.constants as const
except: pass
sympy.init_session()
""".strip("\n")
print("Executing:", *(">>> " + i for i in prog.splitlines()), sep="\n")
exec(prog)
'
end
