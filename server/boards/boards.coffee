scheduleConfirmedEmailText = (opponent, team, matchDate) ->
    return "" +
        "Your match with " + opponent + " from " + team +
        " is scheduled for " + matchDate + ". \n" +
        "WARNING: The date and time in this email are based in UTC timezone. " +
        "The date on schedule page" +
        "(http://world-shogi-league.meteor.com/matches/schedule)" +
        " uses your time zone." +
        "Please be sure to be available at " +
        "81dojo.com at that time."

scheduleCanceledEmailText = (opponent, team) ->
    return "" +
        "Your opponent " + opponent + " from " + team +
        " changed his schedule and the original match date no longer applies." +
        " Please schedule a new date with your opponent in match schedule " +
        " page at http://world-shogi-league.meteor.com/matches/schedule"

playerAddedToBoard = (player, opponentTeam) ->
    return "" +
        "Hi " + player + "! " +
        "Your team head assigned you to a match against " + opponentTeam + "." +
        " Please schedule your game in match schedule" +
        " page at http://world-shogi-league.meteor.com/matches/schedule"

opponentAddedToMatch = (opponent, team) ->
    return "" +
        "Opponent " + opponent + " from " + team +
        " was added to the match by his team head." +
        " Please schedule a game with your opponent in match schedule " +
        " page at http://world-shogi-league.meteor.com/matches/schedule"

updateMatchDate = (boardId) ->
    # Input validation
    throw new Meteor.Error "missing-boardId" if not boardId?.length

    boardData = Boards.findOne boardId
    throw new Meteor.Error "no-such-board" if not boardData?

    otherBoardData = Boards.findOne
        board: boardData.board
        playerId: { $ne: boardData.playerId }
        teamId: { $ne: boardData.teamId }
        matchId: boardData.matchId

    return false if not otherBoardData? or not otherBoardData.schedule?

    matchUnixTime = (()->
        for schedule in boardData.schedule
            start = schedule.startDate.getTime()
            end = schedule.endDate.getTime()

            return false if not otherBoardData.schedule?
            for otherSchedule in otherBoardData.schedule
                otherStart = otherSchedule.startDate.getTime()
                otherEnd = otherSchedule.endDate.getTime()

                if start >=otherStart and start <= otherEnd
                    return start
                if otherStart >= start and otherStart <= end
                    return otherStart
        return false
    )()

    # get team's name of currently logged in user
    teamData = Teams.findOne boardData.teamId

    # get opponent's nick and his team's name
    opponentData = Meteor.users.findOne otherBoardData.playerId
    opponentTeamData = Teams.findOne otherBoardData.teamId

    updateObj = {}
    firstEmail = ""
    secondEmail = ""
    subject = ""
    if not matchUnixTime? or not matchUnixTime
        updateObj = { $unset: { matchDate: "" } }

        subject = "Shogi Match Schedule changed"
        firstEmail = scheduleCanceledEmailText Meteor.user().profile?.nick81Dojo,
        opponentTeamData?.name
    else
        matchDate = new Date(matchUnixTime)
        updateObj = { $set: { matchDate: matchDate } }

        subject = "Shogi Match Scheduled"
        firstEmail = scheduleConfirmedEmailText Meteor.user().profile?.nick81Dojo,
        teamData?.name, matchDate

        secondEmail = scheduleConfirmedEmailText opponentData?.profile?.nick81Dojo,
        opponentTeamData?.name, matchDate

    Boards.update boardId, updateObj
    Boards.update otherBoardData._id, updateObj

    sender = new EmailSender
    sender.sendEmail opponentData?.emails[0].address, subject, firstEmail

    if secondEmail?.length
        sender.sendEmail Meteor.user().emails[0].address, subject, secondEmail


Meteor.methods
    addPlayerToMatch: (userId, matchId, board) ->
        # Access rights
        throw new Meteor.Error "not-authorized" if not isAdminOrHead()

        # Check teamId. Team id of player must be the same as team id of a
        # team in the match
        userData = Meteor.users.findOne userId
        throw new Meteor.Error "user-not-found" if not userData?

        teamId = userData.profile.teamId
        matchData = Matches.findOne matchId
        if teamId != matchData.teamAId and
        teamId != matchData.teamBId
            throw new Meteor.Error "wrong-board-match"

        # Check if this player is already playing in this match
        testBoardData = Boards.findOne
            playerId: userId
            matchId: matchId

        if testBoardData?
            throw new Meteor.Error "player-already-plays",
            "Player is already plaing in this round"

        # Data to update
        boardData =
            playerId: userId
            matchId: matchId
            teamId: teamId
            board: board

        # Check if this board is already occupied
        # If so remove the record, but only if the game is not finished yet
        thisBoard = Boards.findOne
            matchId: matchId
            teamId: teamId
            board: board

        if thisBoard?
            # If game on this board is already finished, trying to replace
            # player is considered an error
            throw new Meteor.Error "board-game-finished" if thisBoard.win?
            Boards.removeBoard thisBoard._id

        # Don't allow any more boards to be added
        allMatchBoards = Boards.find(
            {matchId: matchId, teamId: teamId}
        ).fetch()
        if allMatchBoards.length >= BOARDS_COUNT
            throw new Meteor.Error "too-many-boards"

        Boards.insert boardData

        # Sending emails
        sender = new EmailSender

        # Notify player that he was added to match by email
        opponentTeamId = matchData.teamAId if matchData.teamAId != teamId
        opponentTeamId = matchData.teamBId if matchData.teamBId != teamId
        opponentTeam = Teams.findOne opponentTeamId
        subject = "You were added to a match against " + opponentTeam.name
        addPlayerEmail = playerAddedToBoard userData.profile?.nick81Dojo,
        opponentTeam.name

        sender.sendEmail userData?.emails[0].address, subject, addPlayerEmail

        # If there's already a player from opponent's team waiting, notify him,
        # that he now has an opponent
        opponentBoard = Boards.findOne
            matchId: matchId
            teamId: opponentTeamId
            board: board

        return if not opponentBoard?

        opponentData = Meteor.users.findOne opponentBoard.playerId
        thisTeam = Teams.findOne teamId
        return if not opponentData? or not thisTeam?

        subject = "You have an opponent in World Shogi League"
        email = opponentAddedToMatch userData.profile.nick81Dojo, thisTeam.name

        sender.sendEmail opponentData?.emails[0].address, subject, email

    removePlayerFromMatch: (playerId, matchId) ->
        # Access rights
        throw new Meteor.Error "not-authorized" if not isAdminOrHead()

        # Validation of parameters
        throw new Meteor.Error "playerId-empty" if not playerId?.length
        throw new Meteor.Error "matchId-empty" if not matchId?.length

        board = Boards.findOne
            matchId: matchId
            playerId: playerId
        if not board?
            throw new Meteor.Error "no-such-board", "Player is not playing
            in the selected match"

        # If game on this board is already finished, trying to remove it
        # is considered an error
        throw new Meteor.Error "board-game-finished" if board?.win?

        Boards.removeBoard board._id

    addToSchedule: (boardId, startDateObj, endDateObj)->
        # Access rights
        throw new Meteor.Error "not-authorized" if not Meteor.userId()?.length

        # Input validation
        throw new Meteor.Error "missing-boardId" if not boardId?.length
        throw new Meteor.Error "missing-startDate" if not startDateObj?
        throw new Meteor.Error "missing-endDate" if not endDateObj?

        dateDiff = endDateObj.getTime() - startDateObj.getTime()
        if dateDiff < 0
            throw new Meteor.Error "date-order", "Starting date must be lower
            than ending date"

        board = Boards.findOne boardId
        throw new Meteor.Error "no-such-board" if not board?

        if board.matchDate?
            throw new Meteor.Error "match-negotiated", "Your match date has
            been already negotiated. You can't add another. If you wish to
            change the date, cancel your schedule and negotiate new one"

        # Insert schedule
        scheduleObj =
            _id: new Mongo.ObjectID()._str
            startDate: startDateObj
            endDate: endDateObj

        Boards.update boardId, { $push: { schedule:  scheduleObj}}

        # Update match date
        updateMatchDate(boardId)

    removeFromSchedule: (boardId, scheduleId) ->
        # Access rights
        throw new Meteor.Error "not-authorized" if not Meteor.userId()?.length

        # Input validation
        throw new Meteor.Error "missing-boardId" if not boardId?.length
        throw new Meteor.Error "missing-scheduleId" if not scheduleId?.length

        board = Boards.findOne boardId
        throw new Meteor.Error "no-such-board" if not board?

        if Meteor.userId() != board.playerId
            throw new Meteor.Error "not-authorized"

        # Finally, remove date time from schedule
        Boards.update boardId, { $pull: { schedule: { _id: scheduleId } } }

        # Update match date
        updateMatchDate(boardId)
