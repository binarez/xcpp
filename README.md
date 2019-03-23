# xcpp
Run cpp source code from the command line.

# How does it work?
If you run a file named "filename.xcpp", the launcher compiles your source code and runs the function "filename", which needs to accept the command arguments (reference to vector of strings) and must return an integer (the exit code of the script). Command arguments are forwarded to your C++ code.

# Install
xcpp is self-contained, just download xcpp.sh and copy it somewhere where it can be run (like /usr/local/bin)

# Example :  test.xcpp script
    #!xcpp.sh
        
    int test( strings & args )
    {
        for( string & arg : args )
        {
            println(arg);
        }
        return 0;
    }

To run, just make it executable:

    chmod +x ./test.xcpp

and then run it:

    ./test.xcpp

The launcher will call the "test" function, because the file is named test.xcpp (the extension doesn't matter).
