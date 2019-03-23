# xcpp
Run cpp source code from the command line. If you run a file named "filename.xcpp", the launcher runs the function "filename", which should accept the arguments of the command as a vector of strings reference and returns an integer.

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

The launcher will call the "test" function which should take in a strings (std::vector< std::string >) reference (strings &) and return an integer.
