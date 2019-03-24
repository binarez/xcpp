#!/bin/bash
#------------------------------------------------------------------------------
set -e								# Stop execution on error
xcppVersion=1
#------------------------------------------------------------------------------
xcppGccUserOptions=""
xcppExecutionArgIndex=1
# Eventually, replace -w with -Wno-pragma-once-outside-header : https://gcc.gnu.org/bugzilla/show_bug.cgi?id=89808
readonly xcppGccHardcodedOptions="-pipe -w -x c++"
ProcessXcppGccArgs () {
	i=1;
	for arg in "$@"
	do
		if [[ "$arg" =~ ^-.* ]]; then	# If the argument starts with a -dash
			xcppGccUserOptions="$xcppGccUserOptions $arg"
		elif [ ! -z "$xcppGccUserOptions" ]; then	# Else If we already have gcc options
			((xcppExecutionArgIndex=i))			# We're done
			return
		fi
		((i=i+1))
	done
}
#------------------------------------------------------------------------------
GenerateTempXcppHeader () {
echo "
#ifndef _XCPP_RESERVED_HEADER_H_
#define _XCPP_RESERVED_HEADER_H_

#include <bits/stdc++.h>
using namespace std;

using str = const char *;
using strings = vector< string >;
using size = size_t;
using ssize = ssize_t;

using i8 = uint8_t;
using i16 = uint16_t;
using i32 = uint32_t;
using i64 = uint64_t;

using u8 = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;

using f32 = float;
using f64 = double;
using f128 = __float128; // long double?

template< typename T >
inline bool within(T low, T value, T hi)
{
	return low <= value && value <= hi;
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
inline void read( T & val )
{
	cin >> val;
	cin.ignore(numeric_limits<streamsize>::max(), '\n');
}

inline void readln( string & val )
{
	getline( cin, val );
}

#endif // _XCPP_RESERVED_HEADER_H_
" > "$1"
}
#------------------------------------------------------------------------------
if [[ $# -lt 1 ]]; then				# We need at last one command argument: the source file
    echo "xcpp.sh version $xcppVersion"
	echo ""
	echo "Usage:"
	echo "$0 FILE.xcpp [ARG1 ARG2 ... ARGN]"
	echo ""
	echo "Optionally, specify gcc options:"
	echo "$0 [GCC_OPTIONS] FILE.xcpp [ARG1 ARG2 ... ARGN]"
	echo ""
	echo "For example, to run crunch.xcpp with O3 optimization level and without warnings:"
	echo "$0 -O3 -w crunch.xcpp"
	exit 42
fi
ProcessXcppGccArgs "$@"
tempElfFile=$(mktemp /tmp/xcpp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.elf)
tempIncludeFile=$(mktemp /tmp/xcpp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.h)
trap "{ rm -f $tempElfFile; rm -f $tempIncludeFile; }" EXIT # Trap exit for temp files removal
GenerateTempXcppHeader $tempIncludeFile
funcname=$(basename "${!xcppExecutionArgIndex}")
funcname=${funcname%%.*}
echo "
#include <vector>
#include <string>
int main(int _xcpp_reserved_argc_, const char * _xcpp_reserved_argv_[])
{
	int $funcname( std::vector<std::string> );
	return $funcname( std::vector<std::string>(_xcpp_reserved_argv_ + 1, _xcpp_reserved_argv_ + _xcpp_reserved_argc_) );
}
" | g++ $xcppGccHardcodedOptions -include $tempIncludeFile -DXCPP_VERSION=$xcppVersion $xcppGccUserOptions -o "$tempElfFile" /dev/stdin "${!xcppExecutionArgIndex}";	# Compile
chmod +x "$tempElfFile";	# Make executable
"$tempElfFile" "${@:1}";	# Execute
e="$?";					# Capture exit code
exit "$e";				# Exit with proper exit code