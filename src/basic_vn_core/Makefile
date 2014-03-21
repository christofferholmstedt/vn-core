.PHONY: clean
.PHONY: all

ubuntu: all

ravenscar: clean
	echo "pragma Profile(Ravenscar);" > project_pragmas
	gnatmake -d -p -P basic_vn_core.gpr

restricted: clean
	echo "pragma Profile(Restricted);" > project_pragmas
	gnatmake -d -p -P basic_vn_core.gpr

all: clean
	echo "" > project_pragmas
	gnatmake -d -p -P basic_vn_core.gpr

clean:
	gnat clean -P basic_vn_core.gpr

clean-all:
	gnat clean -r -P basic_vn_core.gpr
