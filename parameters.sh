# Check parameters used by &system.root and export them.
#
# [ Parameters ]
# Parameters are exported for use with all the stages of initialization.
#
# /FAULT_INSTALLATION_PATH/
	# Path to the `python` and `integration` directories that will be setup for use.
# /PYTHON/
	# Path to the python3 executable that initialization should use.
#
# [ Exports ]
# In additional to all the &[Parameters] being exported, the following
# derived values are as well.
#
# /FAULT_PYTHON_PATH/
	# String path identifier for the &<http://fault.io/python> product.
	# Must include the context directory.
# /FAULT_SYSTEM_PATH/
	# String path identifier for the &<http://fault.io/integration> product.
# /FAULT_LIBEXEC_PATH/
	# String path identifier for the location that will contain tool bindings used
	# to support initialization and default construction contexts.
# /PYTHON_PREFIX/
	# The `sys.path` reported by Python.
# /PYTHON_VERSION/
	# The major and minor version reported by Python as a string.
# /PYTHON_ABI/
	# The ABI suffix reported by Python.
# /PYTHON_INCLUDE/
	# The path to the directory containing the Python C interfaces.

# Location of root setup scripts.
if test x"$FAULT_ROOT_PATH" = x""
then
	FAULT_ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
fi
PYX="$FAULT_ROOT_PATH/factor-execute.py"

FAULT_INSTALLATION_PATH="$1"; shift 1
if ! test -d "$FAULT_INSTALLATION_PATH"
then
	echo >&2 "first argument must be the installation directory containing the sources."
	exit 2
fi

PYTHON="$1"; shift 1
if ! test -x "$PYTHON"
then
	echo >&2 "fifth argument must be the selected Python implementation; the system executable."
	exit 100
fi

FAULT_PYTHON_PATH="$FAULT_INSTALLATION_PATH/python/fault"
if ! test -d "$FAULT_PYTHON_PATH"
then
	echo >&2 "python corpus not found in [$FAULT_INSTALLATION_PATH]."
	exit 2
fi

FAULT_SYSTEM_PATH="$FAULT_INSTALLATION_PATH/integration/system"
if ! test -d "$FAULT_SYSTEM_PATH"
then
	echo >&2 "integration corpus not found in [$FAULT_INSTALLATION_PATH]."
	exit 3
fi

FAULT_LIBEXEC_PATH="$FAULT_INSTALLATION_PATH/libexec"
test -d "$FAULT_LIBEXEC_PATH" || mkdir "$FAULT_LIBEXEC_PATH" || exit 4
FAULT_TOOL_PATH="$FAULT_INSTALLATION_PATH/bin"
test -d "$FAULT_TOOL_PATH" || mkdir "$FAULT_TOOL_PATH" || exit 4

# Get final name in path.
if test x"" = "x"$FAULT_CONTEXT_NAME
then
	IFS=/
	for i in $FAULT_PYTHON_PATH
	do
		if ! test x"" = "$i"
		then
			FAULT_CONTEXT_NAME="$i"
		fi
	done
	unset i IFS
fi

epy () { "$PYTHON" -c "$1"; }
PYTHON_PREFIX="$(epy 'import sys; print(sys.prefix)')"
PYTHON_VERSION="$(epy 'import sys; print(".".join(map(str, sys.version_info[:2])))')"
PYTHON_ABI="$(epy 'import sys; print(sys.abiflags)')"
PYTHON_INCLUDE="$PYTHON_PREFIX/include/python$PYTHON_VERSION$PYTHON_ABI"
unset -f epy

export FAULT_ROOT_PATH PYX
export FAULT_TOOL_PATH FAULT_LIBEXEC_PATH
export FAULT_INSTALLATION_PATH FAULT_PYTHON_PATH FAULT_SYSTEM_PATH
export FAULT_CONTEXT_NAME
export PYTHON PYTHON_PREFIX PYTHON_VERSION PYTHON_ABI PYTHON_INCLUDE