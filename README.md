# xcpp

xcpp is convention over configuration for C++. It is a tool that lets you write, run, watch and build C++ code quickly and simply. xcpp stands for execute C++. It compiles and runs your code in a pre-configured environment: you just write C++. The xcpp environment preincludes all C++ Standard Library headers and it is "using namespace std;" all of it for you. In addition to having all the std namespace ready to use, xcpp provides extra basic functions and types to simplify your C++ development, like simplified handling of i/o streams errors (print and read functions), string manipulations (trim, rtrim, ltrim, concat, concat_range) and new algorithms like purge and purge_if algorithms (purge is erase–remove, a well-known C++ idiom).

xcpp can compile with g++ (or gcc) and clang. If your code is processing a lot of data, you will benefit from using xcpp because you will be running directly on the CPU in binary operations instead of being interpreted.

# Install

xcpp is a self-contained bash script: just download the "xcpp" file and copy it where it can be run, like /usr/local/bin or somewhere else that is in your $PATH.

# How does it work?

First, you create a text file (.xcpp extension recommended). The first 7 lines of that file must be:

    #if !defined(__XCPP__)
    #define __XCPP__ 0
    #elif defined(__XCPP__)
    #pragma once
    #else
    . xcpp.sh "$0" "$@"
    #endif

With comments:

    #if !defined(__XCPP__)  // This is the main xcpp file if __XCPP__ is not defined:
    #define __XCPP__ 0        // We're in the main program file, define the xcpp version (0: in development).
    #elif defined(__XCPP__) // Else if __XCPP__ is already defined, we're in header mode:
    #pragma once              // Prevent multi inclusion.
    #else                   // Else: this case is never true so it never reaches the C++ compiler.
    . xcpp.sh "$0" "$@"     // All the previous lines are bash comments, now call the xcpp launcher.
    #endif

After these 7 lines, you are free to write xcpp C++ code and the xcpp tool will be able to run, watch, build and test that code.

If you run a file named "filename.xcpp", the launcher compiles your source code and runs the function "filename". Command arguments are forwarded to your C++ code as strings to this function.

Here's the xcpp hello world example:

    #if !defined(__XCPP__)
    #define __XCPP__ 0
    #elif defined(__XCPP__)
    #pragma once
    #else
    . xcpp.sh "$0" "$@"
    #endif
    
    int hello_world( strings args )
    {
    	println( "Hello, world!" );
    	return 0;
    }

To run, simply:

    xcpp run hello_world.xcpp

Another option: make it executable and then run it, just like a script.

    chmod +x hello_world.xcpp
    ./hello_world.xcpp

The launcher will call the "hello_world" function, because the file is named hello.xcpp -- the extension doesn't matter.

# Example 2:  hello_you.xcpp

    #if !defined(__XCPP__)
    #define __XCPP__ 0
    #elif defined(__XCPP__)
    #pragma once
    #else
    . xcpp.sh "$0" "$@"
    #endif
    
    int hello_you( strings args )
    {
    	string name;
    	print( "What is you name? " );
    	if( readln( name ) )
		{
			println( "Hello, " + name + "!" );
		}
		else
		{
			println( "I'm sorry, I didn't hear ya." );
		}
    	return 0;
    }

# Reserved keywords and identifiers

The xcpp keywords and reserved identifiers are:

* Of course, all the C++ keywords: https://en.cppreference.com/w/cpp/keyword
* Because xcpp preincludes all the C++ standard library, all the std symbols: https://en.cppreference.com/w/cpp/symbol_index
* xcpp adds some of its own identifiers and reserved keywords:
  * concat
  * print
  * println
  * fprint
  * fprintln
  * newline
  * read
  * readln
  * for_i
  * str
  * strings
  * sz
  * ssz
  * i8
  * i16
  * i32
  * i64
  * u8
  * u16
  * u32
  * u64
  * f32
  * f64
  * f128
  * seed_rand
  * purge
  * purge_if
  * within
  * trim
  * rtrim
  * ltrim
  * sleep_ms
  * press_enter
  * main
  * \_\_XCPP_VERSION\_\_
  * \_\_XCPP\_\_
  * \_\_XCPP_RESERVED_HEADER_H\_\_

  # Scratch pad
  
  * Generate xhpp from make_xhpp.sh et un dossier ./src contenant le source de la lib en C++
  
  Example of package structure:
  * stb_perlin
  ** 0.2
  *** make_xhpp.sh
  *** src/
  ** 0.4
  *** make_xhpp.sh
  *** src/
  