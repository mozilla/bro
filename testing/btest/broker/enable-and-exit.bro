# @TEST-REQUIRES: grep -q ENABLE_BROKER:BOOL=true $BUILD/CMakeCache.txt

# @TEST-EXEC: bro -b %INPUT >output
# @TEST-EXEC: btest-diff output

redef exit_only_after_terminate = T;

event terminate_me() {
        print "terminating";
        terminate();
}

event bro_init() {
        Broker::enable();

        print "1";
        schedule 1sec { terminate_me() };
        print "2";
}
