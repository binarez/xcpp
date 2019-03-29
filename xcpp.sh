#!/usr/bin/env bash

# xcpp build
# xcpp clean

# xcpp run_gcc
# xcpp run_clang
# xcpp run_cl
# xcpp build_gcc
# xcpp build_clang
# xcpp build_cl
# xcpp watch_gcc
# xcpp watch_clang
# xcpp watch_cl

# xcpp config -> install to /usr/local/bin ou choix du path dans $PATH ou custom, choix compilateur
# xcpp test -> automatically calls the test function of a .xcpp or .xhpp file
# xcpp time
# xcpp info

# Stop execution on error
set -e

#----[ Constants ] ------------------------------------------------------------
readonly xcppVersion=0
readonly xcppVersionRev=4
readonly xcppGccHardcodedOptions="-pipe -xc++"
readonly xcppWatchDelay=1	# Seconds: 1.5 = 1500 ms

#----[ Variables ] ------------------------------------------------------------
xcppGccUserOptions=""
xcppExecutionArgIndex=1
xcppElfFile=""
xcppIncludeFile=""

#------------------------------------------------------------------------------
# TODO : Generalize this to handle all options, xcpp and compiler options
# Handle setlocale with -xcpp_locale option
# -xcpp_boost option
ProcessXcppGccArgs () {
	i=1;
	for arg in "$@"
	do
		# If the argument starts with a -dash
		if [[ "$arg" =~ ^-.* ]]; then
			xcppGccUserOptions="$xcppGccUserOptions $arg"
		else
			# We're done
			xcppExecutionArgIndex=$i
			return
		fi
		((i=i+1))
	done
	xcppExecutionArgIndex=1
}

#------------------------------------------------------------------------------
# [$1] optional : elf file name
CreateTempFiles () {
	if [[ -z $1 ]]; then
		xcppElfFile=$(mktemp /tmp/xcpp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.elf)
	else
		xcppElfFile="$1"
	fi
	xcppIncludeFile=$(mktemp /tmp/xcpp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.h)
}

#------------------------------------------------------------------------------
CmdPrintHelp () {
    echo "xcpp.sh v$xcppVersion.$xcppVersionRev"
	echo ""
	echo "usage:"
	echo "$0 FILE.xcpp [ARG1 ARG2 ... ARGN]"
	echo ""
	echo "Optionally, specify gcc options:"
	echo "$0 [GCC_OPTIONS] FILE.xcpp [ARG1 ARG2 ... ARGN]"
	echo ""
	echo "For example, to run crunch.xcpp with O3 level and native optimizations:"
	echo "$0 -march=native -O3 crunch.xcpp"
}

#------------------------------------------------------------------------------
HelpRun () {
	echo "Compiles and executes an xcpp file."
    echo "xcpp.sh run FILE.xcpp"
}

#------------------------------------------------------------------------------
HelpBuild () {
	echo "Builds an xcpp file into an executable binary."
    echo "xcpp.sh build FILE.xcpp [FILE.out]"
	echo " FILE.out defaults to FILE.xcpp.out if not specified"
}

#------------------------------------------------------------------------------
HelpWatch () {
	echo "Compiles, executes and monitors changes to an xcpp file."
    echo "xcpp.sh watch FILE.xcpp"
}

#------------------------------------------------------------------------------
HelpNew () {
	echo "Creates a new xcpp file."
    echo "xcpp.sh new FILE.xcpp [FILE2.xcpp ... FILEN.xcpp]"
}

#------------------------------------------------------------------------------
HelpExportHeader () {
	echo "Exports a header file containing the xcpp environment."
    echo "xcpp.sh export_h [FILE.h]"
	echo " FILE.h defaults to xcpp.h if not specified"
}

#------------------------------------------------------------------------------
HelpExportCpp () {
	echo "Exports a single cpp file containing your xcpp program and the xcpp environment. Allows for standalone compilation without xcpp."
    echo "xcpp.sh export INFILE.xcpp OUTFILE.cpp"
}

#------------------------------------------------------------------------------
GenerateXcppHeader () {
	echo "\
#ifndef _XCPP_HEADER_RESERVED_H_
#define _XCPP_HEADER_RESERVED_H_

#define __XCPP_VERSION__ $xcppVersion

#include <bits/stdc++.h>

#define for_i(FORI_TYPE, FORI_FROM, FORI_TO) \\
			  for(FORI_TYPE i{FORI_FROM}; \\
				((FORI_FROM) < (FORI_TO)) ? (i < (FORI_TO)) : (i > (FORI_TO)); \\
				((FORI_FROM) < (FORI_TO)) ? ++i : --i )

using strings = std::vector< std::string >;
using sz = std::size_t;
using ssz = ssize_t;

using i8 = std::int8_t;
using i16 = std::int16_t;
using i32 = std::int32_t;
using i64 = std::int64_t;

using u8 = std::uint8_t;
using u16 = std::uint16_t;
using u32 = std::uint32_t;
using u64 = std::uint64_t;

using f32 = float;
using f64 = double;
using f128 = __float128; // long double?

template <typename T>
auto str(T && val)
{
	return std::to_string(std::forward<T>(val));
}

inline void newline( void )
{
	std::cout << std::endl;
}

template< typename T >
inline bool within( const T & low, const T & value, const T & hi)
{
	return (low <= value) && (value <= hi);
}

template < typename CONTAINER_TYPE, typename VALUE_TYPE >
inline void purge( CONTAINER_TYPE & container, const VALUE_TYPE & value )
{
	container.erase( std::remove( container.begin(), container.end(), value ), container.end() );
}

template < typename CONTAINER_TYPE, typename COMPARE_FUNC >
inline void purge_if( CONTAINER_TYPE & container, const COMPARE_FUNC & func )
{
	container.erase( std::remove_if( container.begin(), container.end(), func ), container.end() );
}

inline int stricmp(const char * a, const char * b)
{
#ifdef _MSC_VER
	return _stricmp(a, b);
#else
	return strcasecmp(a, b);
#endif
}

// trim from start (in place)
inline void ltrim(std::string &s)
{
	s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](int ch) {
		return !std::isspace(ch);
	}));
}

// trim from end (in place)
inline void rtrim(std::string &s)
{
	s.erase(std::find_if(s.rbegin(), s.rend(), [](int ch) {
		return !std::isspace(ch);
	}).base(), s.end());
}

// trim from both ends (in place)
inline void trim(std::string &s)
{
	ltrim(s);
	rtrim(s);
}

template <typename Arg, typename... Args>
inline void fprint(std::ostream & theStream, Arg&& arg, Args&&... args)
{
    theStream << std::forward<Arg>(arg);
    (void)(int[]){0, (void(theStream << std::forward<Args>(args)), 0)...};
}

template <typename Arg, typename... Args>
inline void fprintln(std::ostream & theStream, Arg&& arg, Args&&... args)
{
	fprint( theStream, std::forward<Arg>(arg), std::forward<Args>(args)... );
	theStream << std::endl;
}

template <typename Arg, typename... Args>
inline void print(Arg&& arg, Args&&... args)
{
	fprint( std::cout, std::forward<Arg>(arg), std::forward<Args>(args)... );
}

template <typename Arg, typename... Args>
inline void println(Arg&& arg, Args&&... args)
{
	fprintln( std::cout, std::forward<Arg>(arg), std::forward<Args>(args)... );
}

template <typename Arg, typename... Args>
inline std::string concat(Arg&& arg, Args&&... args)
{
	std::ostringstream ss;
	fprint( ss, std::forward<Arg>(arg), std::forward<Args>(args)... );
	return ss.str();
}

template < typename T >
inline bool read( T & val )
{
	const bool ok{ ( std::cin >> val ) };
	if( !ok )
	{
		std::cin.clear();
	}
	std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
	return ok;
}

inline bool readln( std::string & val )
{
	return static_cast< bool >( std::getline( std::cin, val ) );
}

inline void press_enter()
{
	print(\"Press Enter to continue...\");
	std::cin.get();
}

inline void seed_rand( unsigned int seed = 0 )
{
	if( seed == 0 )
	{
		std::srand( static_cast< unsigned int >( std::time( NULL ) ) );
	}
	else
	{
		std::srand( seed );
	}
}

inline void sleep_ms( sz msTime )
{
	std::this_thread::sleep_for( std::chrono::milliseconds(msTime) );
}

using namespace std;

#endif // _XCPP_HEADER_RESERVED_H_ \
" 		> "$1"
}

#------------------------------------------------------------------------------
OutputXcppMainCpp () {
	echo "\

#include <vector>
#include <string>
/* #include <clocale> */

int main(int _xcpp_reserved_argc_, const char * _xcpp_reserved_argv_[])
{
	/* setlocale( LC_ALL, \"\" ); */
	int $1( std::vector<std::string> );
	return $1( std::vector<std::string>(_xcpp_reserved_argv_ + 1,
										_xcpp_reserved_argv_ + _xcpp_reserved_argc_) );
}\
"
}

#------------------------------------------------------------------------------
ExecuteXcppBinary () {
	chmod +x "$1"	# Make executable
	"$1" "${@:2}"	# Execute
	return $?
}

#------------------------------------------------------------------------------
ExtractFunctionName () {
	local funcname=$(basename "$1")
	funcname=${funcname%%.*}
	funcname="${funcname//[^[:alnum:]]/_}"
	echo $funcname
}

#------------------------------------------------------------------------------
CompileXcpp () {
	echo -ne "Compiling with g++ "
	OutputXcppMainCpp "$1" | 
	g++ $xcppGccHardcodedOptions $xcppGccUserOptions \
		-include "$xcppIncludeFile" -o "$xcppElfFile" \
		/dev/stdin "$2"
	echo -ne "\r                       \r"
}

#------------------------------------------------------------------------------
# Runs an xcpp file
# $1 command: run, defrun, spinrun,
# $2 xcpp file to run
CmdRun () {
	if [[ $# -lt 2 ]]; then
		HelpRun
		return
	fi

	ProcessXcppGccArgs "${@:2}"
	((xcppExecutionArgIndex++))

	CreateTempFiles
	# Trap exit for temp files removal and processes termination
	trap "{ rm -f $xcppElfFile; rm -f $xcppIncludeFile; kill 0; }" EXIT
	GenerateXcppHeader $xcppIncludeFile

	local xcppFunctionName=$(ExtractFunctionName "${!xcppExecutionArgIndex}")
	CompileXcpp "$xcppFunctionName" "${!xcppExecutionArgIndex}"

	if [[ $1 == "runbg" ]]; then
		xcppExitCode=ExecuteXcppBinary "$xcppElfFile" "${@:$xcppExecutionArgIndex}" &
	else
		xcppExitCode=ExecuteXcppBinary "$xcppElfFile" "${@:$xcppExecutionArgIndex}"
	fi
	return $xcppExitCode
}

#------------------------------------------------------------------------------
# Builds an xcpp file
# $1 command: build, build_*
# $2 xcpp file to build
# [$3] optional : output elf file name
CmdBuild () {
	if [[ $# -lt 2 ]]; then
		HelpBuild
		return
	fi
	local elfToBuild="$3"
	if [[ -z "$elfToBuild" ]]; then
		elfToBuild="./$(basename "$2").out"
	elif [[ -d "$elfToBuild" ]]; then
		elfToBuild="$elfToBuild/$(basename "$2").out"
	fi

	ProcessXcppGccArgs "${@:2}"
	((xcppExecutionArgIndex++))

	CreateTempFiles "$elfToBuild"
	# Trap exit for temp files removal and processes termination
	trap "{ rm -f $xcppIncludeFile; }" EXIT
	GenerateXcppHeader $xcppIncludeFile

	local xcppFunctionName=$(ExtractFunctionName "${!xcppExecutionArgIndex}")
	CompileXcpp "$xcppFunctionName" "${!xcppExecutionArgIndex}"
}

#------------------------------------------------------------------------------
# [$1] Header file to produce (output): defaults to xcpp.h if not specified
CmdExportHeader () {
	if [[ $# -lt 1 ]]; then
		set -- xcpp.h
		echo xcpp.h
	elif [[ $# -ne 1 ]]; then
		HelpExportHeader;
		return
	fi

	if [[ -f "$1" ]]; then
		echo xcpp error: \""$1"\" already exists, not overwriting.
	else
		GenerateXcppHeader "$1"
	fi
}

#------------------------------------------------------------------------------
# Export a cpp file from an xcpp file.
# $1 xcpp file (input)
# $2 cpp file (output)
CmdExportCpp () {
	if [[ $# -ne 2 ]]; then
		HelpExportCpp
		return
	elif [[ ! -f "$1" ]]; then
		echo xcpp error: \""$1"\" not found.
	elif [[ -f "$2" ]]; then
		echo xcpp error: \""$2"\" already exists, not overwriting.
	else
		GenerateXcppHeader "$2"
		cat "$1" >> "$2"
		OutputXcppMainCpp $(ExtractFunctionName "$1") >> "$2"
	fi
}

#------------------------------------------------------------------------------
# Kills a process and deletes temp files
# $1 PID
StopProcess () {
	kill -9 $1 &> /dev/null || echo -n ""	# Absorb error
	rm -f "$xcppElfFile"
	xcppElfFile=""
	rm -f "$xcppIncludeFile"
	xcppIncludeFile=""
}

#------------------------------------------------------------------------------
# Observe an xcpp file and re-runs it on change.
# $1 watch command (watch or watch_*)
# $2 xcpp file to watch
CmdWatch () {
	if [[ $# -lt 2 ]]; then
		HelpWatch
		return
	fi
	local lastHash=`sha256sum "$2"`
	CmdRun runbg "${@:2}"
	local watchedPID=$!
	while true; do
	  sleep $xcppWatchDelay
	  local newHash=`sha256sum "$2"`
	  if [ "$newHash" != "$lastHash" ]; then
		clear
		disown
		StopProcess $watchedPID
		CmdRun runbg "${@:2}"
		watchedPID=$!
		lastHash="$newHash"
	  fi
	done
}

#------------------------------------------------------------------------------
CmdNewXcppFiles () {
	if [[ $# -lt 1 ]]; then
		HelpNew
		return
	fi

	for file in "$@"
	do
		if [[ -f "$file" ]]; then
			echo xcpp error: \""$file"\" already exists, not overwriting.
			continue
		fi
		local xcppFunctionName=$(ExtractFunctionName "$file")
		echo "\
#if !defined(__XCPP__)
#define __XCPP__ $xcppVersion
#elif defined(__XCPP__)
#pragma once
#else
. xcpp.sh run \"\$0\" \"\$@\"
#endif

int $xcppFunctionName( strings args )
{
	println( \"Hello, world!\" );
	return 0;
}\
" 		> "$file"
	done
}

#------------------------------------------------------------------------------
Main() {
	if [[ $# -lt 1 ]] || [[ $1 == "help" ]]; then
		CmdPrintHelp
	elif [[ $1 == "-v" ]] || [[ $1 == "version" ]]; then
		echo v"$xcppVersion.$xcppVersionRev"
	elif [[ $1 == "run" ]]; then
		CmdRun "$@"
		exit $?
	elif [[ $1 == "watch" ]]; then
		CmdWatch "$@"
	elif [[ $1 == "build" ]]; then
		CmdBuild "$@"
	elif [[ $1 == "new" ]]; then
		CmdNewXcppFiles "${@:2}"
	elif [[ $1 == "export" ]]; then
		CmdExportCpp "${@:2}"
	elif [[ $1 == "export_h" ]]; then
		CmdExportHeader "${@:2}"
	else # Defaults to run
		CmdRun defrun "$@"
		exit $?
	fi
}

Main "$@"
exit 0