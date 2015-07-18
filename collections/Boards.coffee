BoardsCollection = Mongo.Collection;

BoardsCollection.prototype.removeBoard = (filter) ->
    this.remove filter

@Boards = new BoardsCollection "boards",
    transform: (doc) ->
        scheduleList = doc.schedule
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
