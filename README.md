# xcpp
xcpp stands for eXecute C++: it lets you run C++ source code quickly. xcpp is C++ in a preconfigured environnement in which . There are some downsides to using xcpp:  xcpp lets you write C++ code in a preconfigured environnement in which . xcpp is mainly built for quick, dirty and small programes. You can think of it as C++ scripting if you like. Remember that it is compiled. If you some code processing a lot of data, you will benefit from using xcpp because you will be running . If you are writing You do not have to worry about which part of STL to include: it is all included. Every single C++ standard library is preincluded . You are not permitted to define a main() function.

# How does it work?
If you run a file named "filename.xcpp", the launcher compiles your source code and runs the function "filename", which needs to accept the command arguments (reference to vector of strings) and must return an integer (the exit code of the script). Command arguments are forwarded to your C++ code.

# Install
xcpp is a self-contained bash script, just download xcpp.sh and copy it where it can be run, like /usr/local/bin or somewhere else that is in your $PATH.

# Example 1:  hello.xcpp script
    #if 0
    . xcpp.sh $0 $@
    #endif
    
    int hello( strings & arguments )
    {
        println( "Hello world!" );
        return 0;
    }


To run, first make it executable:

    chmod +x ./hello.xcpp

then run it:

    ./hello.xcpp

The launcher will call the "hello" function, because the file is named hello.xcpp -- the extension doesn't matter.

# Reserved keywords

The xcpp keywords are:
- Of course, all the C++ keywords;
- Because it preincludes all the standard library, all the std:: identifiers declared publicly.
- xcpp adds some of its own keywords:
-- 1
-- 2
