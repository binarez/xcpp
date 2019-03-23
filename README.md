# xcpp
Run cpp source code from the command line

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
