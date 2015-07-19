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
