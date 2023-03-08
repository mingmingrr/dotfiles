function sympy
ipython --matplotlib=tk -i -c '\
prog = """
import sympy
sympy.init_session()
""".strip("\n")
print("Executing:", *(">>> " + i for i in prog.splitlines()), sep="\n")
exec(prog)
'
end
