import GraniteAgents

/// The loom agent's place in Granite's roster: an app that links this package finds the `loom` agent by this
/// record, with nothing listed by hand.
@used @section("__DATA_CONST,__granite")
let loomRecord: GraniteRoster.Record = { GraniteRoster.record(LoomAgent.self) }
