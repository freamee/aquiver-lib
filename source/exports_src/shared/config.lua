local CONFIG = {}

CONFIG.DebugEnabled = false
CONFIG.AQUIVER_TEST_SERVER = false -- Do not mess with this variable, this one is for us for the test server.

if GetConvar("avp_test_server", 'false') == "true" then
    CONFIG.AQUIVER_TEST_SERVER = true
    print("^3Aquiver Products Test Server recognized! ('setr avp_test_server true')")
end

return CONFIG
