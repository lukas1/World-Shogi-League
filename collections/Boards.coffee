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

BoardsCollection = Mongo.Collection;

BoardsCollection.prototype.removeBoard = (boardId) ->
    board = this.findOne boardId
    otherBoardData = Boards.findOne
        matchId: board.matchId
        _id: { $ne: board._id }
    if otherBoardData?
        Boards.update otherBoardData._id, { $unset: { matchDate: "" } }

    this.remove board._id

BoardsCollection.prototype.removeMatchBoards = (matchId) ->
    boards = this.find({matchId: matchId}).fetch()
    for board in boards
        updatePointsSingleTeam board.teamId, board.win, board.winByDefault,
        false

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
