# xcpp

TODO FIX: xcpp stands for eXecute C++: a bash script that runs C++ source code quickly. xcpp is C++ in a preconfigured environnement in which . There are some downsides to using xcpp:  xcpp lets you write C++ code in a preconfigured environnement in which . xcpp is mainly built for quick, dirty and small programes. You can think of it as C++ scripting if you like. Remember that it is compiled. If you some code processing a lot of data, you will benefit from using xcpp because you will be running . If you are writing You do not have to worry about which part of STL to include: it is all included. Every single C++ standard library is preincluded . You are not permitted to define a main() function.

# How does it work?

First, you create a text file (.xcpp extension recommended). The first 4 lines of that file must be:

    #pragma once
    #if 0
    . xcpp.sh $0 $@
    #endif

After that, you are free to write xcpp C++ code.

If you run a file named "filename.xcpp", the launcher compiles your source code and runs the function "filename", which needs to accept the command arguments (reference to vector of strings) and must return an integer (the exit code of the script). Command arguments are forwarded to your C++ code.

# Install
xcpp is a self-contained bash script, just download xcpp.sh and copy it where it can be run, like /usr/local/bin or somewhere else that is in your $PATH.

# Example 1:  hello_world.xcpp script
    #pragma once
    #if 0
    . xcpp.sh $0 $@
    #endif
    
    int hello_world( strings arguments )
    {
    	println( "Hello, world!" );
    	return 0;
    }

To run, first make it executable:

    chmod +x ./hello_world.xcpp

then run it:

    ./hello_world.xcpp

The launcher will call the "hello" function, because the file is named hello.xcpp -- the extension doesn't matter.

# Example 2:  hello_you.xcpp script

    #pragma once
    #if 0
    . xcpp.sh $0 $@
    #endif
    
    int hello_you( strings arguments )
    {
    	string name;
    	print( "What is you name? " );
    	readln( name );
    	println( "Hello, " + name + "!" );
    	return 0;
    }

# Reserved keywords and identifiers

The xcpp keywords and reserved identifiers are:

* Of course, all the C++ keywords: https://en.cppreference.com/w/cpp/keyword
* Because xcpp preincludes all the C++ standard library, all the std symbols: https://en.cppreference.com/w/cpp/symbol_index
* xcpp adds some of its own identifiers
  * read
  * readln
  * print
  * println
  * strings
  * str
  * size
  * ssize
  * seed_rand
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
  * purge
  * purge_if
  * within
  * trim
  * rtrim
  * ltrim
  * press_enter_to_continue
