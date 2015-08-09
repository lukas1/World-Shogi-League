@updatePoints = (winnerBoardId, loserBoardId, add = true) ->
    # Validate input
    throw new Meteor.Error "wrong-parameter" if not winnerBoardId?
    throw new Meteor.Error "wrong-parameter" if not loserBoardId?

    winnerBoard = Boards.findOne winnerBoardId
    loserBoard = Boards.findOne loserBoardId

    return false if not winnerBoard? or not loserBoard?

    return false if not add and not winnerBoard.win? and not loserBoard.win?

    multiplier = 1;
    multiplier = -1 if not add

    # Update points of participating teams
    teamsToUpdate = [
        Teams.findOne winnerBoard.teamId
        Teams.findOne loserBoard.teamId
    ]

    # Select appropriate amount of points to be updated
    for teamData in teamsToUpdate
        do (teamData) ->
            pointsToAdd = 0
            if teamData._id == winnerBoard.teamId
                pointsToAdd = Points.win
            else if winnerBoard.winByDefault
                pointsToAdd = Points.loseDefault
            else
                pointsToAdd = Points.lose

            points = teamData.points + (multiplier * pointsToAdd)

            # Update points for this team
            Teams.update(teamData._id, {$set: {points: points}})

BoardsCollection = Mongo.Collection;

BoardsCollection.prototype.removeBoard = (filter) ->
    boards = this.find(filter).fetch()
    for board in boards
        otherBoardData = Boards.findOne
            matchId: board.matchId
            _id: { $ne: board._id }
        if otherBoardData?
            Boards.update otherBoardData._id, { $unset: { matchDate: "" } }
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
