unixTime = () ->
    return parseInt(Date.now() / 1000)

searchFromDate = unixTime()

@resultsCron = () ->
    return false if not API81DOJOURL? || not API81DOJOAUTH?

    searchUntilDate = unixTime()

    url = API81DOJOURL + "?search_from=" + searchFromDate + "&search_until=" +
    + searchUntilDate

    HTTP.get url, { auth: API81DOJOAUTH }, (error, result) ->
        console.log error if error
        kifus = result.data.kifus
        updateMatchResult match for match in kifus

    searchFromDate = searchUntilDate

updateMatchResult = (match) ->
    # Draws are not allowed, neither is other type of result
    return if match.result != 1 && match.result != 2

    winnerTeamId = ""
    blackData = findUserByNick81Dojo match.black
    return if not blackData?

    whiteData = findUserByNick81Dojo match.white
    return if not whiteData?

    # result = 1 -> black won
    # result = 2 -> white won
    if match.result == 1
        winnerTeamId = blackData.profile.teamId
    else
        winnerTeamId = whiteData.profile.teamId

    blackMatches = matchIdsParticipatedByPlayer blackData._id
    return if not blackMatches?.length

    whiteBoard = Boards.findOne {
        playerId: whiteData._id
        matchId:
            $in: blackMatches
    }

    # If result is already known, don't overwrite it
    return if whiteBoard.win?

    winnerBlock = getWinnerBlock winnerTeamId, whiteBoard.matchId
    return if not winnerBlock

    gameLink = kifuLink match.id

    Meteor.call "postGameResult", whiteBoard.matchId,
    whiteBoard.board, winnerBlock, false, gameLink, (error, result) ->
        # Nothing to do

getWinnerBlock = (winnerTeamId, matchId) ->
    matchData = Matches.findOne matchId
    return false if not matchData?

    winnerBlock = 'a'
    winnerBlock = 'b' if matchData.teamBId == winnerTeamId
    return winnerBlock

kifuLink = (kifuId) ->
    return "http://81dojo.com/kifuviewer.html?kid=" + kifuId
