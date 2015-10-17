dateTimeFormat = 'DD/MM/YYYY HH:mm'

showError = (title, message, top = false) ->
    errorContainer = $('#errorMessageContainer').get(0)
    errorContainer = $('#errorMessageRemoveContainer').get(0) if top
    Template.errorTemplate.showError title, message,
    errorContainer
    return false

opponentBoardData = () ->
    try
        myBoard = boardDataForPlayerId Meteor.userId()
        return board = Boards.findOne
            board: myBoard.board
            playerId: { $ne: Meteor.userId() }
            teamId: { $ne: myBoard.teamId }
            matchId: myBoard.matchId
    catch error
        return null

opponentData = () ->
    try
        board = opponentBoardData()
        user = Meteor.users.findOne board.playerId
        user["email"] = user.emails[0].address
        return user
    catch error
        return null

matchEndDate = () ->
    matchEndDateVar
    try
        matchId = getMatchIdForPlayer Meteor.userId()
        matchData = Matches.findOne matchId
        matchEndDateVar = matchData.matchEndDate
    catch error
        matchEndDateVar = moment().add(8, 'days').toDate()

    return matchEndDateVar

matchDateFinished = () ->
    return moment() > moment(matchEndDate().getTime())

Template.scheduleMatch.helpers
    boardData: ->
        try
            board = boardDataForPlayerId Meteor.userId()
            board["addScheduleClass"] = 'hidden' if board.matchDate?
            board["addScheduleClass"] = 'hidden' if matchDateFinished()
            return board
        catch error
            return null
    opponentBoardData: opponentBoardData
    opponentData: opponentData
    opponentTeamData: ->
        Teams.findOne opponentData().profile.teamId
    matchData: ->
        try
            matchId = getMatchIdForPlayer Meteor.userId()
            return Matches.findOne matchId
        catch error
            return null
    matchDateFinished: matchDateFinished


Template.scheduleMatch.onRendered ->
    if not matchDateFinished()
        this.$('#dateTimeStartPickerText, #dateTimeEndPickerText').datetimepicker
            useCurrent: false
            allowInputToggle: true
            sideBySide: true
            showClear: true
            format: dateTimeFormat
            minDate: new Date()
            maxDate: matchEndDate()
            defaultDate: new Date()

        this.$('#dateTimeStartPickerText').on "dp.change", (e)->
            $('#dateTimeEndPickerText').data("DateTimePicker").minDate(e.date)

        this.$('#dateTimeEndPickerText').on "dp.change", (e)->
            $('#dateTimeStartPickerText').data("DateTimePicker").maxDate(e.date)

Template.scheduleMatch.events
    "submit #addToSchedule": (e, tpl) ->
        e.preventDefault()
        Template.errorTemplate.resetError()

        errorTitle = "Could not add dates to schedule!"

        startDate = $('#dateTimeStartPickerText').find('input').val()
        endDate = $('#dateTimeEndPickerText').find('input').val()
        startDateObj = moment(startDate, dateTimeFormat).toDate()
        endDateObj = moment(endDate, dateTimeFormat).toDate()

        if not startDate?.length
            return showError errorTitle, "Select starting date and time"
        if not endDate?.length
            return showError errorTitle, "Select ending date and time"

        try
            board = boardDataForPlayerId Meteor.userId()

            Meteor.call "addToSchedule", board._id, startDateObj, endDateObj,
            (error, result) ->
                if error
                    return showError errorTitle, error.reason

                # Adding to schedule successful, clear inputs
                $('#dateTimeStartPickerText').find('input').val('')
                $('#dateTimeEndPickerText').find('input').val('')
                $('#dateTimeStartPickerText')
                    .data("DateTimePicker").maxDate(false)
                $('#dateTimeEndPickerText')
                    .data("DateTimePicker").minDate(false)

        catch error
            return showError errorTitle, error.reason

        return false
    "click .cancelSchedule": (e, tpl) ->
        e.preventDefault()
        Template.errorTemplate.resetError()

        return false if not confirm "Do you really want to remove this date
        from your schedule?"

        errorTitle = "Could not remove date from schedule!"
        try
            board = boardDataForPlayerId Meteor.userId()
            scheduleId = $(e.target).attr('id').replace('cancelSchedule', '')

            Meteor.call "removeFromSchedule", board._id, scheduleId,
            (error, result) ->
                if error
                    return showError errorTitle, error.reason, true
        catch error
            return showError errorTitle, error.reason, true

        return false
