// Forces TMXProfiling and TMXProfilingConnections to be linked and embedded
// in the app bundle. DeunaSDK discovers them at runtime via NSClassFromString.
// Without this import, the linker dead-strips the frameworks since no symbol
// is referenced directly from code.
import TMXProfiling
import TMXProfilingConnections
