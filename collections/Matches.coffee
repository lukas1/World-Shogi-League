MatchesCollection = Mongo.Collection;
MatchesCollection.prototype.insertMatch = (matchData) ->
    return false if not isAdmin()

    return false if not matchData.roundId?
    round = Rounds.findOne matchData.roundId
    return false if not round?

    # Insert match
    matchId = this.insert matchData

    # Add match to it's round
    round.matches.push(matchId)
    matches = round.matches
    updated = Rounds.update round._id, {$set: {matches: matches}}
    if not updated
        Matches.removeMatch matchId
        return false
    else
        return matchId

MatchesCollection.prototype.removeMatches = (filter) ->
    return false if not isAdmin()

    matches = Matches.find filter, { fields: {'_id': 1} }
    matches.forEach (document) ->
        Matches.removeMatch document._id

MatchesCollection.prototype.removeMatch = (matchId) ->
    return false if not isAdmin()

    # Validate input
    return false if not matchId?.length

    # Remove all boards with this match id
    Boards.removeMatchBoards matchId

    matchData = this.findOne matchId
    return false if not matchData?

    this.remove matchId

@Matches = new MatchesCollection "matches",
    transform: (doc) ->
        roundData = Rounds.findOne doc.roundId
        doc['roundNumber'] = roundData.roundNumber if roundData?
        return doc

Matches.allow
    insert: -> isAdmin()
    update: -> isAdminOrHead()
    remove: -> isAdmin()
