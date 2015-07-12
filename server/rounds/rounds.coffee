Meteor.methods
    finishRound: (roundId) ->
        throw new Meteor.Error "not-authorized" if not isAdmin()
        round = Rounds.findOne roundId
        if not round?.matches?.length
            throw new Meteor.Error "no-matches-finish",
            "You can't finish a round with no matches"
            return false
        Rounds.update roundId, {$set: {finished: true}}
    removeRound: (roundId) ->
        throw new Meteor.Error "not-authorized" if not isAdmin()
        rounds = Rounds.find({}, {sort: {roundNumber: -1}, limit: 1}).fetch()
        throw new Meteor.Error "empty-rounds" if not rounds?.length

        if roundId != rounds[0]?._id
            throw new Meteor.Error "invalid-round-to-remove",
            "Only last round can be removed"

        Matches.remove {roundId: roundId}
        Rounds.remove _id: roundId
