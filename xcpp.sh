#!/usr/bin/env bash

# xcpp run_gcc
# xcpp run_clang
# xcpp run_cl
# xcpp build
# xcpp build_gcc
# xcpp build_clang
# xcpp build_cl
# xcpp clean
# xcpp watch
# xcpp watch_gcc
# xcpp watch_clang
# xcpp watch_cl
# xcpp install
# xcpp export main.cpp
# xcpp test -> automatically calls the test function of a .xcpp or .xhpp file
# xcpp time
# xcpp info

# Stop execution on error
set -e

#----[ Constants ] ------------------------------------------------------------
readonly xcppVersion=0
readonly xcppVersionRev=2
readonly xcppGccHardcodedOptions="-pipe -xc++"

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
			echo $i
			return
		fi
		((i=i+1))
	done
	echo 1
}

#------------------------------------------------------------------------------
CreateTempFiles () {
	xcppElfFile=$(mktemp /tmp/xcpp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.elf)
	xcppIncludeFile=$(mktemp /tmp/xcpp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.h)

	# Trap exit for temp files removal
	trap "{ rm -f $xcppElfFile; rm -f $xcppIncludeFile; }" EXIT
}

#------------------------------------------------------------------------------
CmdPrintHelp () {
    echo "xcpp.sh version $xcppVersion.$xcppVersionRev"
	echo ""
	echo "Usage:"
	echo "$0 FILE.xcpp [ARG1 ARG2 ... ARGN]"
	echo ""
	echo "Optionally, specify gcc options:"
	echo "$0 [GCC_OPTIONS] FILE.xcpp [ARG1 ARG2 ... ARGN]"
	echo ""
	echo "For example, to run crunch.xcpp with O3 level and native optimizations:"
	echo "$0 -march=native -O3 crunch.xcpp"
}

#------------------------------------------------------------------------------
GenerateXcppHeader () {
	echo "\
#ifndef _XCPP_HEADER_RESERVED_H_
#define _XCPP_HEADER_RESERVED_H_

#define __XCPP_VERSION__ $xcppVersion

#include <bits/stdc++.h>
using namespace std;

#define for_i(FORI_TYPE, FORI_FROM, FORI_TO) \\
			  for(FORI_TYPE i{FORI_FROM}; \\
				((FORI_FROM) < (FORI_TO)) ? (i < (FORI_TO)) : (i > (FORI_TO)); \\
				((FORI_FROM) < (FORI_TO)) ? ++i : --i )

using strings = vector< string >;
using sz = size_t;
using ssz = ssize_t;

using i8 = int8_t;
using i16 = int16_t;
using i32 = int32_t;
using i64 = int64_t;

using u8 = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;

using f32 = float;
using f64 = double;
using f128 = __float128; // long double?

template <typename... Args>
auto str(Args&&... args) -> decltype(std::to_string(std::forward<Args>(args)...))
{
	return std::to_string(std::forward<Args>(args)...);
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
	container.erase( remove( container.begin(), container.end(), value ), container.end() );
}

template < typename CONTAINER_TYPE, typename COMPARE_FUNC >
inline void purge_if( CONTAINER_TYPE & container, const COMPARE_FUNC & func )
{
	container.erase( remove_if( container.begin(), container.end(), func ), container.end() );
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
inline void ltrim(string &s)
{
	s.erase(s.begin(), find_if(s.begin(), s.end(), [](int ch) {
		return !isspace(ch);
	}));
}

// trim from end (in place)
inline void rtrim(string &s)
{
	s.erase(find_if(s.rbegin(), s.rend(), [](int ch) {
		return !isspace(ch);
	}).base(), s.end());
}

// trim from both ends (in place)
inline void trim(string &s)
{
	ltrim(s);
	rtrim(s);
}

template < typename T >
inline void print( const T & val )
{
	cout << val;
}

template < typename T >
inline void println( const T & val )
{
	cout << val << endl;
}

template < typename T >
inline bool read( T & val )
{
	const bool ok{ ( cin >> val ) };
	if( !ok )
	{
		cin.clear();
	}
	cin.ignore(numeric_limits<streamsize>::max(), '\n');
	return ok;
}

inline bool readln( string & val )
{
	return static_cast< bool >( getline( cin, val ) );
}

inline void press_enter()
{
	print(\"Press Enter to continue...\");
	cin.get();
}

inline void seed_rand( unsigned int seed = 0 )
{
	if( seed == 0 )
	{
		srand( static_cast< unsigned int >( time( NULL ) ) );
	}
	else
	{
		srand( seed );
	}
}

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
HelpRun () {
	echo "Compiles and executes an xcpp file."
    echo "xcpp.sh run FILE.xcpp"
}

#------------------------------------------------------------------------------
CmdRun () {
	if [[ $# -lt 2 ]]; then
		HelpRun
		return
	fi
	xcppExecutionArgIndex=$(ProcessXcppGccArgs "${@:2}")
	((xcppExecutionArgIndex++))
	CreateTempFiles
	GenerateXcppHeader $xcppIncludeFile
	local xcppFunctionName=$(ExtractFunctionName "${!xcppExecutionArgIndex}")
	CompileXcpp "$xcppFunctionName" "${!xcppExecutionArgIndex}"
	xcppExitCode=ExecuteXcppBinary "$xcppElfFile" "${@:$xcppExecutionArgIndex}"
	exit $xcppExitCode
}

#------------------------------------------------------------------------------
HelpNew () {
	echo "Creates a new xcpp file."
    echo "xcpp.sh new FILE.xcpp [FILE2.xcpp ... FILEN.xcpp]"
}

#------------------------------------------------------------------------------
HelpExportHeader () {
	echo "Exports a header file containing the xcpp environment."
    echo "xcpp.sh export_h FILE.h [FILE2.h ... FILEN.h]"
}

#------------------------------------------------------------------------------
HelpExportCpp () {
	echo "Exports a single cpp file containing your xcpp program and the xcpp environment. Allows for standalone compilation without xcpp."
    echo "xcpp.sh export INFILE.xcpp OUTFILE.cpp"
}

#------------------------------------------------------------------------------
CmdExportHeader () {
	if [[ $# -lt 1 ]]; then
		set -- xcpp.h
	fi
	for file in "$@"
	do
		if [[ -f "$file" ]]; then
			echo xcpp error: \""$file"\" already exists, not overwriting.
			continue
		fi
		GenerateXcppHeader "$file"
	done
}

#------------------------------------------------------------------------------
CmdExportCpp () {
	if [[ $# -ne 2 ]]; then
		HelpExportCpp
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
	elif [[ $1 == "run" ]]; then
		CmdRun "$@"
	elif [[ $1 == "new" ]]; then
		CmdNewXcppFiles "${@:2}"
	elif [[ $1 == "export" ]]; then
		CmdExportCpp "${@:2}"
	elif [[ $1 == "export_h" ]]; then
		CmdExportHeader "${@:2}"
	else
		CmdRun run "$@"
	fi
}

Main "$@"
exit 0