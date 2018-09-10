#!/bin/sh
#--------------------------------------------------------------------------#

usage () {
cat <<EOF
Usage: VAR=VALUE $0 [<build type>] [<option> ...]

Build types:
  production
  debug
  testing
  competition


General options;
  -h, --help               display this help and exit
  --build-dir-prefix       prefix build directory with given prefix
  --best                   turn on dependences known to give best performance
  --gpl                    permit GPL dependences, if available


Features:
The following flags enable optional features (disable with --no-<option name>).
  --static                 build static libraries and binaries [default=no]
  --proofs                 support for proof generation
  --optimized              optimize the build
  --debug-symbols          include debug symbols
  --valgrind               Valgrind instrumentation
  --debug-context-mm       use the debug context memory manager
  --statistics             do not include statistics
  --replay                 turn off the replay feature
  --assertions             turn off assertions
  --tracing                remove all tracing code
  --dumping                remove all dumping code
  --muzzle                 complete silence (no non-result output)
  --coverage               support for gcov coverage testing
  --profiling              support for gprof profiling
  --unit-testing           support for unit testing

The following options configure parameterized features.

  --language-bindings[=c,c++,java,all]
                          specify language bindings to build

Optional Packages:
The following flags enable optional packages (disable with --no-<option name>).
  --cln                    use CLN instead of GMP
  --gmp                    use GMP instead of CLN
  --glpk                   use GLPK simplex solver
  --abc                    use the ABC AIG library
  --cadical                use the CaDiCaL SAT solver
  --cryptominisat          use the CRYPTOMINISAT sat solver
  --lfsc                   use the LFSC proof checker
  --symfpu                 use symfpu for floating point solver
  --portfolio              build the multithreaded portfolio version of CVC4
                           (pcvc4)
  --readline               support the readline library

Optional Path to Optional Packages:
  --abc-dir=PATH           path to top level of abc source tree
  --antlr-dir=PATH         path to ANTLR C headers and libraries
  --cadical-dir=PATH       path to top level of CaDiCaL source tree
  --cryptominisat-dir=PATH path to top level of cryptominisat source tree
  --cxxtest-dir=DIR        path to CxxTest installation
  --glpk-dir=PATH          path to top level of glpk installation
  --lfsc-dir=PATH          path to top level of lfsc source tree
  --symfpu-dir=PATH        path to top level of symfpu source tree

Report bugs to <cvc4-bugs@cs.stanford.edu>.
EOF
  exit 0
}

#To assign environment variables (e.g., CC, CFLAGS...), specify them as
#VAR=VALUE.  See below for descriptions of some of the useful variables.
#
#Some influential environment variables:
#  CXX         C++ compiler command
#  CXXFLAGS    C++ compiler flags
#  LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
#              nonstandard directory <lib dir>
#  LIBS        libraries to pass to the linker, e.g. -l<library>
#  CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
#              you have headers in a nonstandard directory <include dir>
#  CC          C compiler command
#  CFLAGS      C compiler flags
#  LT_SYS_LIBRARY_PATH
#              User-defined run-time library search path.
#  CPP         C preprocessor
#  CXXCPP      C++ preprocessor
#  PKG_CONFIG  path to pkg-config utility
#  CLN_CFLAGS  C compiler flags for CLN, overriding pkg-config
#  CLN_LIBS    linker flags for CLN, overriding pkg-config
#  GLPK_HOME   path to top level of glpk installation
#  ABC_HOME    path to top level of abc source tree
#  CADICAL_HOME
#              path to top level of CaDiCaL source tree
#  CRYPTOMINISAT_HOME
#              path to top level of cryptominisat source tree
#  LFSC_HOME   path to top level of LFSC source tree
#  SYMFPU_HOME path to top level of symfpu source tree
#  ANTLR       location of the antlr3 script
#  DOXYGEN_PAPER_SIZE
#              a4wide (default), a4, letter, legal or executive
#  CXXTEST     path to CxxTest installation
#  TEST_CPPFLAGS
#              CPPFLAGS to use when testing (default=$CPPFLAGS)
#  TEST_CXXFLAGS
#              CXXFLAGS to use when testing (default=$CXXFLAGS)
#  TEST_LDFLAGS
#              LDFLAGS to use when testing (default=$LDFLAGS)
#  PERL        PERL interpreter (used when testing)
#  PYTHON      the Python interpreter
#  ANTLR_HOME  path to libantlr3c installation
#  SWIG        SWIG binary (used to generate language bindings)
#  JAVA_CPPFLAGS
#              flags to pass to compiler when building Java bindings
#  CSHARP_CPPFLAGS
#              flags to pass to compiler when building C# bindings
#  PERL_CPPFLAGS
#              flags to pass to compiler when building perl bindings
#  PHP_CPPFLAGS
#              flags to pass to compiler when building PHP bindings
#  PYTHON_INCLUDE
#              Include flags for python, bypassing python-config
#  PYTHON_CONFIG
#              Path to python-config
#  RUBY_CPPFLAGS
#              flags to pass to compiler when building ruby bindings
#  TCL_CPPFLAGS
#              flags to pass to compiler when building tcl bindings
#  OCAMLC      OCaml compiler
#  OCAMLMKTOP  OCaml runtime-maker
#  OCAMLFIND   OCaml-find binary
#  CAMLP4O     camlp4o binary
#  BOOST_ROOT  Location of Boost installation
#  JAVA        Java interpreter (used when testing Java interface)
#  JAVAC       Java compiler (used when building and testing Java interface)
#  JAVAH       Java compiler (used when building and testing Java interface)
#  JAR         Jar archiver (used when building Java interface)
#
#Use these variables to override the choices made by `configure' or to help
#it to find libraries and programs with nonstandard names/locations.


#--------------------------------------------------------------------------#

die () {
  echo "*** configure.sh: $*" 1>&2
  exit 1
}

msg () {
  echo "[configure.sh] $*"
}

#--------------------------------------------------------------------------#

[ ! -e src/theory ] && die "$0 not called from CVC4 base directory"

#--------------------------------------------------------------------------#

builddir=default
prefix=""

#--------------------------------------------------------------------------#

buildtype=default

abc=default
asan=default
assertions=default
best=default
cadical=default
cln=default
coverage=default
cryptominisat=default
debug_symbols=default
debug_context_mm=default
dumping=default
gpl=default
glpk=default
lfsc=default
muzzle=default
optimized=default
portfolio=default
proofs=default
replay=default
shared=default
statistics=default
symfpu=default
tracing=default
unit_testing=default
valgrind=default
profiling=default
readline=default

language_bindings=default

abc_dir=default
antlr_dir=default
cadical_dir=default
cryptominisat_dir=default
cxxtest_dir=default
glpk_dir=default
lfsc_dir=default
symfpu_dir=default

#--------------------------------------------------------------------------#

while [ $# -gt 0 ]
do
  case $1 in

    -h|--help) usage;;

    --abc) abc=ON;;
    --no-abc) abc=OFF;;

    --asan) asan=ON;;
    --no-asan) asan=OFF;;

    --assertions) assertions=ON;;
    --no-assertions) assertions=OFF;;

    --best) best=ON;;
    --no-best) best=OFF;;

    --build-dir-prefix)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --build-dir-prefix"
      fi
      prefix=$1
      ;;

    --cadical) cadical=ON;;
    --no-cadical) cadical=OFF;;

    --cln) cln=ON;;
    --no-cln) cln=OFF;;

    --coverage) coverage=ON;;
    --no-coverage) coverage=OFF;;

    --cryptominisat) cryptominisat=ON;;
    --no-cryptominisat) cryptominisat=OFF;;

    --debug-symbols) debug_symbols=ON;;
    --no-debug-symbols) debug_symbols=OFF;;

    --debug-context-memory-manager) debug_context_mm=ON;;
    --no-debug-context-memory-manager) debug_context_mm=OFF;;

    --dumping) dumping=ON;;
    --no-dumping) dumping=OFF;;

    --gpl) gpl=ON;;
    --no-gpl) gpl=OFF;;

    --glpk) glpk=ON;;
    --no-glpk) glpk=OFF;;

    --lfsc) lfsc=ON;;
    --no-lfsc) lfsc=OFF;;

    --muzzle) muzzle=ON;;
    --no-muzzle) muzzle=OFF;;

    --optimized) optimized=ON;;
    --no-optimized) optimized=OFF;;

    --portfolio) portfolio=ON;;
    --no-portfolio) portfolio=OFF;;

    --proofs) proofs=ON;;
    --no-proofs) proofs=OFF;;

    --replay) replay=ON;;
    --no-replay) replay=OFF;;

    --static) shared=OFF;;
    --no-static) shared=ON;;

    --statistics) statistics=ON;;
    --no-statistics) statistics=OFF;;

    --symfpu) symfpu=ON;;
    --no-symfpu) symfpu=OFF;;

    --tracing) tracing=ON;;
    --no-tracing) tracing=OFF;;

    --unit-testing) unit_testing=ON;;
    --no-unit-testing) unit_testing=OFF;;

    --valgrind) valgrind=ON;;
    --no-valgrind) valgrind=OFF;;

    --profiling) profiling=ON;;
    --no-profiling) profiling=OFF;;

    --readline) readline=ON;;
    --no-readline) readline=OFF;;

    --language-bindings)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --language-bindings-dir"
      fi
      [[ "c c++ java all" =~ (^|[[:space:]])"$1"($|[[:space:]]) ]] \
        || die "invalid argument to --language-bindings (try '-h')"
      language_bindings=$1
      ;;

    --abc-dir)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --abc-dir"
      fi
      abc_dir=$1
      ;;
    --antlr-dir)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --antlr-dir"
      fi
      antlr_dir=$1
      ;;
    --cadical-dir)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --cadical-dir"
      fi
      cadical_dir=$1
      ;;
    --cryptominisat-dir)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --cryptominisat-dir"
      fi
      cryptominisat_dir=$1
      ;;
    --cxxtest-dir)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --cxxtest-dir"
      fi
      cxxtest_dir=$1
      ;;
    --glpk-dir)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --glpk-dir"
      fi
      glpk_dir=$1
      ;;
    --lfsc-dir)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --lfsc-dir"
      fi
      lfsc_dir=$1
      ;;
    --symfpu-dir)
      shift
      if [ $# -eq 0 ]
      then
        die "missing argument to --symfpu-dir"
      fi
      symfpu_dir=$1
      ;;

    -*) die "invalid option '$1' (try '-h')";;

    *) case $1 in
         production)  buildtype=Production; builddir=production;;
         debug)       buildtype=Debug; builddir=debug;;
         testing)     buildtype=Testing; builddir=testing;;
         competition) buildtype=Competition; builddir=competition;;
         *)           die "invalid build type (try '-h')";;
       esac
       ;;
  esac
  shift
done

builddir="$prefix$builddir"

#--------------------------------------------------------------------------#

cmake_opts=""

[ $buildtype != default ] && cmake_opts="$cmake_opts -DCMAKE_BUILD_TYPE=$buildtype"

[ $asan != default ] \
  && cmake_opts="$cmake_opts -DENABLE_ASAN=$asan" \
  && [ $asan = ON ] && builddir="$builddir-asan"
[ $assertions != default ] \
  && cmake_opts="$cmake_opts -DENABLE_ASSERTIONS=$assertions" \
  && [ $assertions = ON ] && builddir="$builddir-assertions"
[ $best != default ] \
  && cmake_opts="$cmake_opts -DENABLE_BEST=$best" \
  && [ $best = ON ] && builddir="$builddir-best"
[ $coverage != default ] \
  && cmake_opts="$cmake_opts -DENABLE_COVERAGE=$coverage" \
  && [ $coverage = ON ] && builddir="$builddir-coverage"
[ $debug_symbols != default ] \
  && cmake_opts="$cmake_opts -DENABLE_DEBUG_SYMBOLS=$debug_symbols" \
  && [ $debug_symbols = ON ] && builddir="$builddir-debug_symbols"
[ $debug_context_mm != default ] \
  && cmake_opts="$cmake_opts -DENABLE_DEBUG_CONTEXT_MM=$debug_context_mm" \
  && [ $debug_context_mm = ON ] &&  builddir="$builddir-debug_context_mm"
[ $dumping != default ] \
  && cmake_opts="$cmake_opts -DENABLE_DUMPING=$dumping" \
  && [ $dumping = ON ] &&  builddir="$builddir-dumping"
[ $gpl != default ] \
  && cmake_opts="$cmake_opts -DENABLE_GPL=$gpl" \
  && [ $gpl = ON ] &&  builddir="$builddir-gpl"
[ $muzzle != default ] \
  && cmake_opts="$cmake_opts -DENABLE_MUZZLE=$muzzle" \
  && [ $muzzle = ON ] &&  builddir="$builddir-muzzle"
[ $optimized != default ] \
  && cmake_opts="$cmake_opts -DENABLE_OPTIMIZED=$optimized" \
  && [ $optimized = ON ] &&  builddir="$builddir-optimized"
[ $portfolio != default ] \
  && cmake_opts="$cmake_opts -DENABLE_PORTFOLIO=$portfolio" \
  && [ $portfolio = ON ] &&  builddir="$builddir-portfolio"
[ $proofs != default ] \
  && cmake_opts="$cmake_opts -DENABLE_PROOFS=$proofs" \
  && [ $proofs = ON ] &&  builddir="$builddir-proofs"
[ $replay != default ] \
  && cmake_opts="$cmake_opts -DENABLE_REPLAY=$replay" \
  && [ $replay = ON ] &&  builddir="$builddir-replay"
[ $shared != default ] \
  && cmake_opts="$cmake_opts -DENABLE_STATIC=$shared" \
  && [ $shared == OFF ] &&  builddir="$builddir-static"
[ $statistics != default ] \
  && cmake_opts="$cmake_opts -DENABLE_STATISTICS=$statistics" \
  && [ $statistics = ON ] && builddir="$builddir-stastitics"
[ $tracing != default ] \
  && cmake_opts="$cmake_opts -DENABLE_TRACING=$tracing" \
  && [ $tracing = ON ] && builddir="$builddir-tracing"
[ $unit_testing != default ] \
  && cmake_opts="$cmake_opts -DENABLE_UNIT_TESTING=$unit_testing" \
  && [ $unit_testing = ON ] && builddir="$builddir-unit_testing"
[ $valgrind != default ] \
  && cmake_opts="$cmake_opts -DENABLE_VALGRIND=$valgrind" \
  && [ $valgrind = ON ] && builddir="$builddir-valgrind"
[ $profiling != default ] \
  && cmake_opts="$cmake_opts -DENABLE_PROFILING=$profiling" \
  && [ $profiling = ON ] && builddir="$builddir-profiling"
[ $readline != default ] \
  && cmake_opts="$cmake_opts -DENABLE_READLINE=$readline" \
  && [ $readline = ON ] && builddir="$builddir-readline"
[ $abc != default ] \
  && cmake_opts="$cmake_opts -DUSE_ABC=$abc" \
  && [ $abc = ON ] && builddir="$builddir-abc"
[ $cadical != default ] \
  && cmake_opts="$cmake_opts -DUSE_CADICAL=$cadical" \
  && [ $cadical = ON ] && builddir="$builddir-cadical"
[ $cln != default ] \
  && cmake_opts="$cmake_opts -DUSE_CLN=$cln" \
  && [ $cln = ON ] && builddir="$builddir-cln"
[ $cryptominisat != default ] \
  && cmake_opts="$cmake_opts -DUSE_CRYPTOMINISAT=$cryptominisat" \
  && [ $cryptominisat = ON ] && builddir="$builddir-cryptominisat"
[ $glpk != default ] \
  && cmake_opts="$cmake_opts -DUSE_GLPK=$glpk" \
  && [ $glpk = ON ] && builddir="$builddir-glpk"
[ $lfsc != default ] \
  && cmake_opts="$cmake_opts -DUSE_LFSC=$lfsc" \
  && [ $lfsc = ON ] && builddir="$builddir-lfsc"
[ $symfpu != default ] \
  && cmake_opts="$cmake_opts -DUSE_SYMFPU=$symfpu" \
  && [ $symfpu = ON ] && builddir="$builddir-symfpu"

[ $language_bindings != default ] \
  && cmake_opts="$cmake_opts -DENABLE_LANGUAGE_BINDINGS=$language_bindings" \

[ $abc_dir != default ] \
  && cmake_opts="$cmake_opts -DENABLE_ABC_DIR=$abc_dir" \
[ $antlr_dir != default ] \
  && cmake_opts="$cmake_opts -DENABLE_ANTLR_DIR=$antlr_dir" \
[ $cadical_dir != default ] \
  && cmake_opts="$cmake_opts -DENABLE_CADICAL_DIR=$cadical_dir" \
[ $cryptominisat_dir != default ] \
  && cmake_opts="$cmake_opts -DENABLE_CRYPTOMINISAT_DIR=$cryptominisat_dir" \
[ $cxxtest_dir != default ] \
  && cmake_opts="$cmake_opts -DENABLE_CXXTEST_DIR=$cxxtest_dir" \
[ $glpk_dir != default ] \
  && cmake_opts="$cmake_opts -DENABLE_GLPL_DIR=$glpk_dir" \
[ $lfsc_dir != default ] \
  && cmake_opts="$cmake_opts -DENABLE_LFSC_DIR=$lfsc_dir" \
[ $symfpu_dir != default ] \
  && cmake_opts="$cmake_opts -DENABLE_SYMFPU_DIR=$symfpu_dir" \

mkdir -p cmake-builds  # builds parent directory
cd cmake-builds
ln -s $builddir build  # link to current build directory
mkdir -p $builddir     # current build directory
cd $builddir

[ -e CMakeCache.txt ] && rm CMakeCache.txt
cmake ../.. $cmake_opts