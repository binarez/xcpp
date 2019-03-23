# xcpp
Run cpp source code from the command line

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
