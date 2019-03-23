# xcpp
 xcpp stands for eXecute C++, it lets you run C++ source code from the command line.

# How does it work?
If you run a file named "filename.xcpp", the launcher compiles your source code and runs the function "filename", which needs to accept the command arguments (reference to vector of strings) and must return an integer (the exit code of the script). Command arguments are forwarded to your C++ code.

# Install
xcpp is self-contained, just download xcpp.sh and copy it somewhere where it can be run (like /usr/local/bin)

# Example :  hello.xcpp script
    #if 0
    . xcpp.sh $0 $@
    #endif
    
    int hello( strings & arguments )
    {
        println( "Hello world!" );
        return 0;
    }


To run, just make it executable:

    chmod +x ./hello.xcpp

and then run it:

    ./hello.xcpp

The launcher will call the "hello" function, because the file is named hello.xcpp (the extension doesn't matter).
