@updatePoints = (winnerBoardId, loserBoardId, add = true) ->
    # Validate input
    throw new Meteor.Error "wrong-parameter" if not winnerBoardId?
    throw new Meteor.Error "wrong-parameter" if not loserBoardId?

    winnerBoard = Boards.findOne winnerBoardId
    loserBoard = Boards.findOne loserBoardId

    return false if not winnerBoard? or not loserBoard?
    return false if not add and not winnerBoard.win? and not loserBoard.win?

    # Update points of participating teams
    updatePointsSingleTeam winnerBoard.teamId, true, winnerBoard.winByDefault,
    add
    updatePointsSingleTeam loserBoard.teamId, false, loserBoard.winByDefault,
    add

playerRemovedFromMatch = (player) ->
    return "" +
        "Hi " + player + "!\n" +
        "You were removed from the match by your team head. " +
        "Any schedule arrangements you may have done with your opponent are" +
        " no longer valid and your match was canceled."

opponentRemovedFromMatch = (opponent, team) ->
    return "" +
        "Opponent " + opponent + " from " + team +
        " was removed from the match by his team head. " +
        "Please wait until team head of opposing team assigns you an opponent. " +
        "Schedule suggestions you made to your previous opponent are still " +
        "remembered. You can also add new schedule suggestions any time at " +
        "http://world-shogi-tournament.meteor.com/matches/schedule"

BoardsCollection = Mongo.Collection;

BoardsCollection.prototype.removeBoard = (boardId) ->
    board = this.findOne boardId
    otherBoardData = Boards.findOne
        matchId: board.matchId
        _id: { $ne: board._id }

    sender = new EmailSender
    thisUser = Meteor.users.findOne board.playerId
    if otherBoardData?
        Boards.update otherBoardData._id, { $unset: { matchDate: "" } }

        # Send email to opponent
        thisTeam = Teams.findOne board.teamId
        otherPlayerData = Meteor.users.findOne otherBoardData.playerId

        if thisUser? and thisTeam? and otherPlayerData?
            subject = "Your opponent in World Shogi Tournament was removed from the match"
            email = opponentRemovedFromMatch thisUser.profile.nick81Dojo, thisTeam.name

            sender.sendEmail otherPlayerData.emails[0].address, subject, email

    # Notify the player that was removed by email
    if thisUser?
        subject = "Your were removed from a match in World Shogi Tournament"
        email = playerRemovedFromMatch thisUser.profile.nick81Dojo

        sender.sendEmail thisUser.emails[0].address, subject, email

    Kifu.remove board.kifu
    this.remove board._id

BoardsCollection.prototype.removeMatchBoards = (matchId) ->
    boards = this.find({matchId: matchId}).fetch()
    for board in boards
        updatePointsSingleTeam board.teamId, board.win, board.winByDefault,
        false

        Kifu.remove board.kifu
        this.remove board._id

@Boards = new BoardsCollection "boards",
    transform: (doc) ->
        # Sort schedules by date start
        scheduleList = doc.schedule
        return doc if not scheduleList?
        scheduleList.sort (a,b) ->
            return -1 if a.startDate.getTime() < b.startDate.getTime()
            return 1 if a.startDate.getTime() > b.startDate.getTime()
            return 0

        for schedule in scheduleList
            schedule['startDateFormatted'] =
                moment(schedule.startDate).format('MMMM Do, HH:mm')
            schedule['endDateFormatted'] =
                moment(schedule.endDate).format('MMMM Do, HH:mm')

        doc.schedule = scheduleList
        return doc

Boards.allow
    insert: -> isAdminOrHead()
    update: -> isAdminOrHead()
    remove: -> isAdminOrHead()
