#!/bin/bash
set -e								# Stop executing on error
tmpfile="/tmp/xcpp.$(uuidgen).elf"	# Generate temp ELF filename
trap "{ rm -f $tmpfile; }" EXIT		# Trap exit for temp file removal
filename=$(basename "$1")
filename=${filename%%.*}
(echo "
#include <bits/stdc++.h>
using namespace std;

using str = const char *;
using strings = vector< string >;
using size = size_t;

template< typename T >
bool within(T low, T hi, T value)
{
	return low <= value && value <= hi;
}

template < typename CONTAINER_TYPE, typename VALUE_TYPE >
void purge( CONTAINER_TYPE & container, const VALUE_TYPE & value )
{
	container.erase( remove( container.begin(), container.end(), value ), container.end() );
}

template < typename CONTAINER_TYPE, typename COMPARE_FUNC >
void purge_if( CONTAINER_TYPE & container, const COMPARE_FUNC & func )
{
	container.erase( remove_if( container.begin(), container.end(), func ), container.end() );
}

int stricmp(const char * a, const char * b)
{
#ifdef _MSC_VER
	return _stricmp(a, b);
#else
	return strcasecmp(a, b);
#endif
}

// trim from start (in place)
void ltrim(string &s)
{
	s.erase(s.begin(), find_if(s.begin(), s.end(), [](int ch) {
		return !isspace(ch);
	}));
}

// trim from end (in place)
void rtrim(string &s)
{
	s.erase(find_if(s.rbegin(), s.rend(), [](int ch) {
		return !isspace(ch);
	}).base(), s.end());
}

// trim from both ends (in place)
void trim(string &s)
{
	ltrim(s);
	rtrim(s);
}

// trim from start (copying)
string ltrim_copy(string s)
{
	ltrim(s);
	return s;
}

// trim from end (copying)
string rtrim_copy(string s)
{
	rtrim(s);
	return s;
}

// trim from both ends (copying)
string trim_copy(string s)
{
	trim(s);
	return s;
}

template < typename T >
void print( const T & val )
{
	cout << val;
}

template < typename T >
void println( const T & val )
{
	cout << val << endl;
}

template < typename T >
void read( T & val )
{
	cin >> val;
	cin.ignore(numeric_limits<streamsize>::max(), '\n');
}

void readln( string & val )
{
	getline( cin, val );
}
" && (cat "$1" | sed '/^#!/ d') && echo "
int main(int _xcpp_reserved_argc_, str _xcpp_reserved_argv_[])
{
	strings _xcpp_reserved_args_(_xcpp_reserved_argv_ + 1, _xcpp_reserved_argv_ + _xcpp_reserved_argc_);
	return $filename( _xcpp_reserved_args_ );
}
") | g++ -x c++ -DXCPP=1 -o "$tmpfile" -;	# Compile
chmod +x "$tmpfile";	# Make executable
"$tmpfile" "${@:1}";	# Execute
e="$?";					# Capture exit code
rm -f "$tmpfile";		# Remove temp file
exit "$e";				# Exit with proper exit code
